import { localDb, type ChapterMeta, type LocalVolume } from './localDb'
import { parseEpub, type ParsedEpub } from './parseEpub'
import { decodeText, parseTxt, PARSER_VERSION } from './parseTxt'
import { BOOKS_BUCKET, supabase } from './supabase'
import type { Book, BookFormat, BookStatus, ParsedBook, Progress } from './types'

export interface LibraryItem {
  book: Book
  progress: Progress | null
}

export interface Toc {
  volumes: LocalVolume[]
  chapters: ChapterMeta[]
}

// ── nén / giải nén (file TXT nén gzip còn khoảng 1/3) ───────────────────────
async function gzip(data: Uint8Array<ArrayBuffer>): Promise<Blob> {
  const stream = new Blob([data]).stream().pipeThrough(new CompressionStream('gzip'))
  return new Response(stream).blob()
}

async function gunzip(blob: Blob): Promise<Uint8Array<ArrayBuffer>> {
  const stream = blob.stream().pipeThrough(new DecompressionStream('gzip'))
  return new Uint8Array(await new Response(stream).arrayBuffer())
}

async function requireUserId(): Promise<string> {
  const { data } = await supabase.auth.getSession()
  const id = data.session?.user.id
  if (!id) throw new Error('Chưa đăng nhập')
  return id
}

/** Ghi kết quả tách chương vào IndexedDB (ghi đè bản cũ của sách đó). */
async function cacheParsed(bookId: string, parsed: ParsedBook): Promise<void> {
  await localDb.transaction('rw', localDb.volumes, localDb.chapters, localDb.texts, async () => {
    await Promise.all([
      localDb.volumes.where('bookId').equals(bookId).delete(),
      localDb.chapters.where('bookId').equals(bookId).delete(),
      localDb.texts.where('bookId').equals(bookId).delete(),
    ])
    await localDb.volumes.bulkPut(parsed.volumes.map((v) => ({ ...v, bookId })))
    await localDb.chapters.bulkPut(
      parsed.chapters.map(({ text, ...meta }) => ({ ...meta, bookId, charLength: text.length })),
    )
    await localDb.texts.bulkPut(parsed.chapters.map((c) => ({ bookId, index: c.index, text: c.text })))
  })
}

export type ImportStage = 'reading' | 'parsing' | 'uploading' | 'saving'
export type ImportProgress = (stage: ImportStage, done?: number, total?: number) => void

/** Tách nội dung file gốc (đã giải nén) theo định dạng. */
async function parseFile(format: BookFormat, bytes: Uint8Array, onProgress?: ImportProgress): Promise<ParsedEpub | ParsedBook> {
  if (format === 'epub') return parseEpub(bytes, (d, t) => onProgress?.('parsing', d, t))
  return parseTxt(decodeText(bytes))
}

export function formatOf(fileName: string): BookFormat {
  if (/\.epub$/i.test(fileName)) return 'epub'
  if (/\.txt$/i.test(fileName)) return 'txt'
  throw new Error('Chỉ hỗ trợ file .epub và .txt')
}

/**
 * Nhập một file sách: tách chương → tải file gốc (+ ảnh bìa) lên Storage
 * → tạo dòng `books` → cache trên máy. Tên/tác giả lấy từ EPUB nếu không truyền vào.
 */
export async function importBook(
  file: File,
  meta: { title?: string; author?: string } = {},
  onProgress?: ImportProgress,
): Promise<Book> {
  const userId = await requireUserId()
  const format = formatOf(file.name)

  onProgress?.('reading')
  const raw = new Uint8Array(await file.arrayBuffer())
  onProgress?.('parsing')
  const parsed = await parseFile(format, raw, onProgress)
  if (parsed.totalChars === 0) throw new Error('File không có nội dung')
  const epub = 'cover' in parsed ? parsed : null

  const id = crypto.randomUUID()
  // TXT nén gzip (còn ~1/3); EPUB vốn đã là file zip nên giữ nguyên.
  const filePath = format === 'txt' ? `${userId}/${id}.txt.gz` : `${userId}/${id}.epub`
  const body = format === 'txt' ? await gzip(raw) : new Blob([raw], { type: 'application/epub+zip' })
  const coverPath = epub?.cover ? `${userId}/${id}.cover.${epub.cover.mime.split('/')[1] ?? 'img'}` : null

  onProgress?.('uploading')
  const up = await supabase.storage.from(BOOKS_BUCKET).upload(filePath, body, { upsert: false })
  if (up.error) throw up.error
  if (coverPath && epub?.cover) {
    const coverBlob = new Blob([epub.cover.bytes], { type: epub.cover.mime })
    const c = await supabase.storage.from(BOOKS_BUCKET).upload(coverPath, coverBlob, { upsert: true })
    if (!c.error) await localDb.covers.put({ bookId: id, blob: coverBlob })
  }

  onProgress?.('saving')
  const { data: book, error } = await supabase
    .from('books')
    .insert({
      id,
      title: meta.title?.trim() || epub?.title || file.name.replace(/\.[^.]+$/, ''),
      author: meta.author?.trim() || epub?.author || null,
      file_path: filePath,
      file_format: format,
      cover_path: coverPath,
      parser_version: PARSER_VERSION,
      chapter_count: parsed.chapters.length,
      total_chars: parsed.totalChars,
    })
    .select()
    .single<Book>()
  if (error) {
    await supabase.storage.from(BOOKS_BUCKET).remove(coverPath ? [filePath, coverPath] : [filePath])
    throw error
  }

  await cacheParsed(id, parsed)
  await localDb.books.put(book)
  return book
}

/** URL tạm (blob:) của ảnh bìa, cache trên máy. null nếu sách không có bìa. Nhớ URL.revokeObjectURL khi không dùng. */
export async function getCoverUrl(book: Book): Promise<string | null> {
  if (!book.cover_path) return null
  let cached = await localDb.covers.get(book.id)
  if (!cached) {
    const { data, error } = await supabase.storage.from(BOOKS_BUCKET).download(book.cover_path)
    if (error) return null
    cached = { bookId: book.id, blob: data }
    await localDb.covers.put(cached)
  }
  return URL.createObjectURL(cached.blob)
}

/** Danh sách sách + tiến độ. Mất mạng thì trả bản cache. */
export async function listLibrary(): Promise<LibraryItem[]> {
  let books: Book[]
  let remoteProgress: Progress[] = []
  try {
    const [b, p] = await Promise.all([
      supabase.from('books').select('*').order('updated_at', { ascending: false }),
      supabase.from('progress').select('book_id, chapter_index, char_offset, percent, updated_at'),
    ])
    if (b.error) throw b.error
    if (p.error) throw p.error
    books = b.data as Book[]
    remoteProgress = p.data as Progress[]
    await localDb.transaction('rw', localDb.books, async () => {
      await localDb.books.clear()
      await localDb.books.bulkPut(books)
    })
  } catch {
    books = await localDb.books.orderBy('updated_at').reverse().toArray()
  }

  const local = new Map((await localDb.progress.toArray()).map((p) => [p.book_id, p]))
  const remote = new Map(remoteProgress.map((p) => [p.book_id, p]))
  return books.map((book) => ({
    book,
    progress: newer(local.get(book.id) ?? null, remote.get(book.id) ?? null),
  }))
}

function newer<T extends { updated_at: string }>(a: T | null, b: T | null): T | null {
  if (!a) return b
  if (!b) return a
  return a.updated_at >= b.updated_at ? a : b
}

export async function getBook(bookId: string): Promise<Book> {
  const { data, error } = await supabase.from('books').select('*').eq('id', bookId).maybeSingle<Book>()
  if (!error && data) {
    await localDb.books.put(data)
    return data
  }
  const cached = await localDb.books.get(bookId)
  if (cached) return cached
  throw error ?? new Error('Không tìm thấy sách')
}

/** Đảm bảo nội dung sách có sẵn trên máy; chưa có thì tải file gốc về và tách chương. */
export async function ensureBookCached(book: Book): Promise<void> {
  const count = await localDb.chapters.where('bookId').equals(book.id).count()
  if (count > 0 && count === book.chapter_count) return

  const { data, error } = await supabase.storage.from(BOOKS_BUCKET).download(book.file_path)
  if (error) throw error
  const bytes = book.file_path.endsWith('.gz') ? await gunzip(data) : new Uint8Array(await data.arrayBuffer())
  await cacheParsed(book.id, await parseFile(book.file_format, bytes))
}

export async function getToc(bookId: string): Promise<Toc> {
  const [volumes, chapters] = await Promise.all([
    localDb.volumes.where('bookId').equals(bookId).sortBy('index'),
    localDb.chapters.where('bookId').equals(bookId).sortBy('index'),
  ])
  return { volumes, chapters }
}

export async function getChapterText(bookId: string, index: number): Promise<string> {
  const row = await localDb.texts.get([bookId, index])
  if (!row) throw new Error(`Không có nội dung chương ${index}`)
  return row.text
}

export type BookPatch = Partial<Pick<Book, 'title' | 'author' | 'rating' | 'review'>>

export async function updateBook(bookId: string, patch: BookPatch & Partial<Pick<Book, 'status' | 'started_at' | 'finished_at'>>): Promise<Book> {
  const { data, error } = await supabase.from('books').update(patch).eq('id', bookId).select().single<Book>()
  if (error) throw error
  await localDb.books.put(data)
  return data
}

/** Đổi trạng thái và tự điền ngày bắt đầu / ngày đọc xong. */
export async function setStatus(book: Book, status: BookStatus): Promise<Book> {
  const now = new Date().toISOString()
  if (status === 'to_read') return updateBook(book.id, { status, started_at: null, finished_at: null })
  if (status === 'reading') return updateBook(book.id, { status, started_at: book.started_at ?? now, finished_at: null })
  return updateBook(book.id, { status, started_at: book.started_at ?? now, finished_at: now })
}

export async function deleteBook(book: Book): Promise<void> {
  const { error } = await supabase.from('books').delete().eq('id', book.id)
  if (error) throw error
  await supabase.storage.from(BOOKS_BUCKET).remove(book.cover_path ? [book.file_path, book.cover_path] : [book.file_path])
  await localDb.transaction(
    'rw',
    [localDb.books, localDb.volumes, localDb.chapters, localDb.texts, localDb.progress, localDb.covers],
    async () => {
      await localDb.books.delete(book.id)
      await localDb.covers.delete(book.id)
      await localDb.progress.delete(book.id)
      await localDb.volumes.where('bookId').equals(book.id).delete()
      await localDb.chapters.where('bookId').equals(book.id).delete()
      await localDb.texts.where('bookId').equals(book.id).delete()
    },
  )
}

/** Tách nội dung chương thành đoạn, kèm vị trí ký tự đầu mỗi đoạn trong chương. */
export function splitParagraphs(text: string): { start: number; text: string }[] {
  const out: { start: number; text: string }[] = []
  let start = 0
  for (const p of text.split('\n')) {
    out.push({ start, text: p })
    start += p.length + 1
  }
  return out
}
