import Dexie, { type Table } from 'dexie'
import type { Book, Bookmark, Chapter, Note, Progress, Volume } from './types'

/** Thông tin chương (không kèm nội dung) — đủ để vẽ mục lục. */
export type ChapterMeta = Omit<Chapter, 'text'> & { bookId: string; charLength: number }
export type LocalVolume = Volume & { bookId: string }
export interface ChapterText {
  bookId: string
  index: number
  text: string
}
export interface CoverCache {
  bookId: string
  blob: Blob
}
/** synced: 0 = chưa đẩy lên server, 1 = đã đồng bộ (Dexie không index được boolean). */
export type LocalProgress = Progress & { synced: 0 | 1 }
export type LocalBookmark = Bookmark & { synced: 0 | 1 }
export type LocalNote = Note & { synced: 0 | 1 }

export interface OutboxItem {
  id?: number
  table: 'progress' | 'bookmarks' | 'notes'
  op: 'upsert' | 'delete'
  rowId: string
  payload?: Record<string, unknown>
}

export interface PageCountCache {
  bookId: string
  /** hash(cỡ chữ, giãn dòng, font, w×h trang) */
  key: string
  chapterIndex: number
  pageCount: number
}

/** Cache trên máy (IndexedDB). Nguồn sự thật vẫn là Supabase. */
export class LocalDb extends Dexie {
  books!: Table<Book, string>
  volumes!: Table<LocalVolume, [string, number]>
  chapters!: Table<ChapterMeta, [string, number]>
  texts!: Table<ChapterText, [string, number]>
  progress!: Table<LocalProgress, string>
  covers!: Table<CoverCache, string>
  bookmarks!: Table<LocalBookmark, string>
  notes!: Table<LocalNote, string>
  outbox!: Table<OutboxItem, number>
  pageCounts!: Table<PageCountCache, [string, string, number]>

  constructor() {
    super('doc-sach')
    this.version(1).stores({
      books: 'id, updated_at',
      volumes: '[bookId+index], bookId',
      chapters: '[bookId+index], bookId',
      texts: '[bookId+index], bookId',
      progress: 'book_id, synced',
      covers: 'bookId',
    })
    this.version(2).stores({
      bookmarks: 'id, book_id, [book_id+chapter_index], synced',
      notes: 'id, book_id, [book_id+chapter_index], synced',
      outbox: '++id, [table+rowId], table',
      pageCounts: '[bookId+key+chapterIndex], [bookId+key], bookId',
    })
  }
}

export const localDb = new LocalDb()
