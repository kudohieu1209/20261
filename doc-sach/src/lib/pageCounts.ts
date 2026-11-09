import { useLiveQuery } from 'dexie-react-hooks'
import { useEffect, useRef } from 'react'
import { getChapterText } from './books'
import { localDb, type ChapterMeta } from './localDb'

export interface MeasureParams {
  width: number
  height: number
  colWidth: number
  colGap: number
  fontFamily: string
  fontSize: string
  lineHeight: number
  isSpread: boolean
}

let measureContainer: HTMLDivElement | null = null

function getMeasureContainer(): HTMLDivElement | null {
  if (typeof document === 'undefined') return null
  if (!measureContainer) {
    measureContainer = document.createElement('div')
    measureContainer.id = 'doc-sach-measure-container'
    Object.assign(measureContainer.style, {
      position: 'fixed',
      top: '-99999px',
      left: '-99999px',
      visibility: 'hidden',
      pointerEvents: 'none',
      zIndex: '-1',
      overflow: 'hidden',
    })
    document.body.appendChild(measureContainer)
  }
  return measureContainer
}

/** Tạo khoá cache dựa trên toàn bộ các tham số dàn trang. */
export function computePageKey(
  font: string,
  fontSize: string,
  lineHeight: number,
  width: number,
  height: number,
  isSpread: boolean,
): string {
  return `${font}_${fontSize}_${lineHeight}_${isSpread ? '2' : '1'}_${Math.round(width)}x${Math.round(height)}`
}

/** Đo số trang của một chương bằng khung render ẩn. */
export function measureChapterPageCount(text: string, p: MeasureParams): number {
  if (!text || p.width <= 0 || p.height <= 0) return 1
  const container = getMeasureContainer()
  if (!container) return 1

  Object.assign(container.style, {
    width: `${p.width}px`,
    height: `${p.height}px`,
    columnWidth: `${p.colWidth}px`,
    columnGap: `${p.colGap}px`,
    columnFill: 'auto',
    fontFamily: p.fontFamily,
    fontSize: p.fontSize,
    lineHeight: `${p.lineHeight}`,
  })

  const paragraphs = text.split('\n').filter(Boolean)
  container.innerHTML = paragraphs
    .map((txt) => `<p style="margin:0 0 0.5em 0; text-indent:1.5em;">${txt}</p>`)
    .join('')

  const scrollW = container.scrollWidth
  const pages = Math.max(1, Math.round((scrollW + p.colGap) / (p.colWidth + p.colGap)))
  container.innerHTML = ''
  return pages
}

/** Chạy nền đếm số trang toàn bộ các chương trong sách khi trình duyệt rảnh. */
export function startBackgroundPageCount(
  bookId: string,
  chapters: ChapterMeta[],
  key: string,
  params: MeasureParams,
): () => void {
  let cancelled = false
  let idleHandle: number | undefined

  const scheduleNext = (fn: () => void) => {
    if (typeof window !== 'undefined' && 'requestIdleCallback' in window) {
      idleHandle = (window as unknown as { requestIdleCallback: (cb: () => void, opts?: { timeout: number }) => number }).requestIdleCallback(fn, { timeout: 2000 })
    } else {
      idleHandle = setTimeout(fn, 100) as unknown as number
    }
  }

  void (async () => {
    try {
      // Lấy danh sách các chương đã được tính toán trong Dexie
      const cached = await localDb.pageCounts.where('[bookId+key]').equals([bookId, key]).toArray()
      const cachedSet = new Set(cached.map((c) => c.chapterIndex))

      const missing = chapters.filter((c) => !cachedSet.has(c.index))
      let idx = 0

      const processNext = async () => {
        if (cancelled || idx >= missing.length) return

        const ch = missing[idx++]
        try {
          const rawText = await getChapterText(bookId, ch.index)
          if (!cancelled && rawText) {
            const pageCount = measureChapterPageCount(rawText, params)
            await localDb.pageCounts.put({
              bookId,
              key,
              chapterIndex: ch.index,
              pageCount,
            })
          }
        } catch {
          // Bỏ qua lỗi đọc chương
        }

        if (!cancelled && idx < missing.length) {
          scheduleNext(() => void processNext())
        }
      }

      if (missing.length > 0) {
        scheduleNext(() => void processNext())
      }
    } catch {
      // IndexedDB bận
    }
  })()

  return () => {
    cancelled = true
    if (typeof window !== 'undefined' && 'cancelIdleCallback' in window && idleHandle) {
      ;(window as unknown as { cancelIdleCallback: (id: number) => void }).cancelIdleCallback(idleHandle)
    } else if (idleHandle) {
      clearTimeout(idleHandle)
    }
  }
}

/**
 * Hook trả về tổng số trang toàn sách [totalPages] và trang hiện tại [globalPage].
 * Nếu chưa đếm xong thì isComplete = false (khi đó UI hiển thị %).
 */
export function useGlobalPageCount(
  bookId: string | undefined,
  chapters: ChapterMeta[] | undefined,
  params: MeasureParams | null,
  currentChapterIndex: number,
  currentPageInChapter: number,
) {
  const key = params
    ? computePageKey(
        params.fontFamily,
        params.fontSize,
        params.lineHeight,
        params.width,
        params.height,
        params.isSpread,
      )
    : ''

  // Tự động kích hoạt đếm trang nền khi có đủ thông tin
  const cleanupRef = useRef<(() => void) | null>(null)
  useEffect(() => {
    if (!bookId || !chapters || chapters.length === 0 || !params || !key) return
    cleanupRef.current?.()
    cleanupRef.current = startBackgroundPageCount(bookId, chapters, key, params)
    return () => {
      cleanupRef.current?.()
    }
  }, [bookId, chapters, key, params])

  const cached = useLiveQuery(
    async () => {
      if (!bookId || !key) return []
      return localDb.pageCounts.where('[bookId+key]').equals([bookId, key]).toArray()
    },
    [bookId, key],
    [],
  )

  const totalChapters = chapters?.length ?? 0
  const isComplete = totalChapters > 0 && (cached?.length ?? 0) >= totalChapters

  if (!isComplete || !cached) {
    return { globalPage: null, totalPages: null, isComplete: false }
  }

  const map = new Map(cached.map((c) => [c.chapterIndex, c.pageCount]))
  let totalPages = 0
  let pagesBefore = 0

  for (let i = 0; i < totalChapters; i++) {
    const pCount = map.get(i) ?? 1
    if (i < currentChapterIndex) {
      pagesBefore += pCount
    }
    totalPages += pCount
  }

  const globalPage = Math.min(totalPages, pagesBefore + currentPageInChapter)
  return { globalPage, totalPages, isComplete: true }
}
