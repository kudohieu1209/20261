import { useCallback, useEffect, useMemo, useRef, useState } from 'react'
import { ensureBookCached, getBook, getChapterText, getToc, setStatus, splitParagraphs, type Toc } from '../lib/books'
import type { ChapterMeta } from '../lib/localDb'
import { getProgress, saveProgress } from '../lib/progress'
import type { Book } from '../lib/types'

export interface ReaderState {
  book: Book | null
  toc: Toc | null
  chapter: ChapterMeta | null
  /** Đoạn văn của chương hiện tại, kèm vị trí ký tự đầu đoạn */
  paragraphs: { start: number; text: string }[]
  /** Vị trí ký tự cần cuộn/lật tới khi vừa mở chương (null = đầu chương) */
  restoreOffset: number | null
  /** 0..1 trên toàn sách */
  percent: number
  loading: boolean
  error: string | null
}

/**
 * Toàn bộ logic của màn hình đọc: tải sách, mục lục, chương, khôi phục và lưu vị trí.
 * UI gọi `goToChapter`, `nextChapter`, `prevChapter`, `reportPosition`.
 */
export function useReader(bookId: string) {
  const [book, setBook] = useState<Book | null>(null)
  const [toc, setToc] = useState<Toc | null>(null)
  const [chapterIndex, setChapterIndex] = useState<number | null>(null)
  const [text, setText] = useState('')
  const [restoreOffset, setRestoreOffset] = useState<number | null>(null)
  const [percent, setPercent] = useState(0)
  const [loading, setLoading] = useState(true)
  const [error, setError] = useState<string | null>(null)
  const bookRef = useRef<Book | null>(null)

  // Mở sách: tải về máy nếu cần, lấy mục lục và vị trí đọc lần trước.
  useEffect(() => {
    let cancelled = false
    void (async () => {
      try {
        setLoading(true)
        let b = await getBook(bookId)
        await ensureBookCached(b)
        const [t, p] = await Promise.all([getToc(bookId), getProgress(bookId)])
        if (b.status === 'to_read') b = await setStatus(b, 'reading').catch(() => b)
        if (cancelled) return
        bookRef.current = b
        setBook(b)
        setToc(t)
        setPercent(p?.percent ?? 0)
        setRestoreOffset(p?.char_offset ?? null)
        setChapterIndex(Math.min(p?.chapter_index ?? 0, t.chapters.length - 1))
      } catch (e) {
        if (!cancelled) setError((e as Error).message)
      } finally {
        if (!cancelled) setLoading(false)
      }
    })()
    return () => {
      cancelled = true
    }
  }, [bookId])

  // Tải nội dung khi đổi chương.
  useEffect(() => {
    if (chapterIndex === null) return
    let cancelled = false
    void getChapterText(bookId, chapterIndex)
      .then((t) => !cancelled && setText(t))
      .catch((e: Error) => !cancelled && setError(e.message))
    return () => {
      cancelled = true
    }
  }, [bookId, chapterIndex])

  const chapter = toc && chapterIndex !== null ? (toc.chapters[chapterIndex] ?? null) : null
  const paragraphs = useMemo(() => splitParagraphs(text), [text])

  /** UI báo vị trí đang đọc (ký tự đầu tiên đang hiển thị trong chương). */
  const reportPosition = useCallback(
    async (charOffset: number) => {
      const b = bookRef.current
      if (!b || !chapter) return
      const rec = await saveProgress(b, chapter, charOffset)
      setPercent(rec.percent)
    },
    [chapter],
  )

  const goToChapter = useCallback(
    (index: number, offset: number | null = null) => {
      if (!toc || index < 0 || index >= toc.chapters.length) return
      setRestoreOffset(offset)
      setChapterIndex(index)
      const b = bookRef.current
      if (b) void saveProgress(b, toc.chapters[index], offset ?? 0).then((r) => setPercent(r.percent))
    },
    [toc],
  )

  const nextChapter = useCallback(() => chapterIndex !== null && goToChapter(chapterIndex + 1), [chapterIndex, goToChapter])
  const prevChapter = useCallback(() => chapterIndex !== null && goToChapter(chapterIndex - 1), [chapterIndex, goToChapter])

  const isLastChapter = toc !== null && chapterIndex === toc.chapters.length - 1

  /** Gọi khi người đọc tới trang cuối của chương cuối. */
  const markFinished = useCallback(async () => {
    const b = bookRef.current
    if (!b || b.status === 'finished') return
    const updated = await setStatus(b, 'finished')
    bookRef.current = updated
    setBook(updated)
  }, [])

  const state: ReaderState = { book, toc, chapter, paragraphs, restoreOffset, percent, loading, error }
  return { ...state, isLastChapter, reportPosition, goToChapter, nextChapter, prevChapter, markFinished }
}
