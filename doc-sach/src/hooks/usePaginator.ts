import { useCallback, useEffect, useLayoutEffect, useMemo, useRef, useState } from 'react'

/** Bề rộng tối thiểu (px) của vùng đọc để bật chế độ 2 trang (màn ngang). */
const SPREAD_MIN_WIDTH = 900

export interface PageRange {
  start: number
  end: number
}

export interface UsePaginatorOptions {
  containerRef: React.RefObject<HTMLElement | null>
  contentRef: React.RefObject<HTMLElement | null>
  text: string
  chapterIndex: number
  restoreOffset: number | 'end' | null
  isLastChapter: boolean
  onNextChapter: () => void
  onPrevChapter: () => void
  onReportPosition?: (charOffset: number) => void
  onMarkFinished?: () => void
}

export interface PaginatorState {
  page: number
  pageCount: number
  spread: boolean
  spreadIndex: number
  spreadCount: number
  pageRange: PageRange
  colWidth: number
  colGap: number
  containerWidth: number
  containerHeight: number
  next: () => void
  prev: () => void
  goToOffset: (offset: number) => void
  remeasure: () => void
}

const DEFAULT_GAP = 40

export function usePaginator({
  containerRef,
  contentRef,
  text,
  chapterIndex,
  restoreOffset,
  isLastChapter,
  onNextChapter,
  onPrevChapter,
  onReportPosition,
  onMarkFinished,
}: UsePaginatorOptions): PaginatorState {
  const [spreadIndex, setSpreadIndex] = useState(0)
  const [totalPages, setTotalPages] = useState(1)
  const [isSpread, setIsSpread] = useState(false)
  const [dims, setDims] = useState({ width: 0, height: 0, colWidth: 0, colGap: DEFAULT_GAP })
  const [pageRange, setPageRange] = useState<PageRange>({ start: 0, end: 0 })

  const spreadIndexRef = useRef(0)
  const lastCharOffsetRef = useRef<number>(0)
  const isInitialRestoreRef = useRef(true)

  useEffect(() => {
    isInitialRestoreRef.current = true
  }, [chapterIndex])

  // 1. Xác định chế độ 2 trang hay 1 trang và kích thước cột
  const measureDimensions = useCallback(() => {
    const container = containerRef.current
    if (!container) return null

    // Đo vùng nội dung thật (trừ padding), nếu không cột sẽ cao/rộng hơn vùng nhìn thấy
    const cs = getComputedStyle(container)
    const padX = parseFloat(cs.paddingLeft) + parseFloat(cs.paddingRight)
    const padY = parseFloat(cs.paddingTop) + parseFloat(cs.paddingBottom)
    const width = container.clientWidth - padX
    const height = container.clientHeight - padY
    if (width <= 0 || height <= 0) return null

    // Quyết định 1/2 trang theo khoảng trống của phần tử cha, không theo chính container:
    // container bị giới hạn maxWidth theo chế độ hiện tại, đo nó sẽ khoá cứng ở 1 trang.
    const available = container.parentElement?.clientWidth ?? container.clientWidth
    const spread = available >= SPREAD_MIN_WIDTH && available > container.clientHeight
    const colGap = spread ? 48 : 32
    const colWidth = spread ? (width - colGap) / 2 : width

    return { width, height, spread, colWidth, colGap }
  }, [containerRef])

  // 2. Tính ký tự tại vị trí toạ độ màn hình (x, y)
  const getCharOffsetAtPoint = useCallback(
    (x: number, y: number): number | null => {
      const content = contentRef.current
      if (!content || typeof document === 'undefined') return null

      let node: Node | null = null
      let offset = 0

      // Chuẩn W3C mới: caretPositionFromPoint
      if (document.caretPositionFromPoint) {
        const pos = document.caretPositionFromPoint(x, y)
        if (pos) {
          node = pos.offsetNode
          offset = pos.offset
        }
      } else if ((document as unknown as { caretRangeFromPoint?: (x: number, y: number) => Range | null }).caretRangeFromPoint) {
        // WebKit / Chrome fallback
        const range = (document as unknown as { caretRangeFromPoint: (x: number, y: number) => Range | null }).caretRangeFromPoint(x, y)
        if (range) {
          node = range.startContainer
          offset = range.startOffset
        }
      }

      if (!node) return null

      // Tìm phần tử cha chứa data-offset
      const pEl = (node.nodeType === Node.ELEMENT_NODE ? (node as Element) : node.parentElement)?.closest('[data-offset]') as HTMLElement | null
      if (!pEl) return null

      const baseOffset = Number(pEl.dataset.offset || 0)
      try {
        const r = document.createRange()
        r.setStart(pEl, 0)
        r.setEnd(node, offset)
        return baseOffset + r.toString().length
      } catch {
        return baseOffset
      }
    },
    [contentRef],
  )

  // 3. Tính khoảng ký tự [start, end] đang hiển thị trên spread hiện tại
  const computePageRange = useCallback((): PageRange => {
    const container = containerRef.current
    if (!container) return { start: 0, end: 0 }

    const rect = container.getBoundingClientRect()
    const startOffset =
      getCharOffsetAtPoint(rect.left + 24, rect.top + 32) ??
      lastCharOffsetRef.current ??
      0

    const endOffset =
      getCharOffsetAtPoint(rect.right - 24, rect.bottom - 32) ??
      Math.max(startOffset, text.length)

    return { start: startOffset, end: endOffset }
  }, [containerRef, getCharOffsetAtPoint, text.length])

  // 4. Tìm spread chứa một charOffset
  const findSpreadForOffset = useCallback(
    (targetOffset: number, totalCols: number, spread: boolean, colWidth: number, colGap: number): number => {
      const content = contentRef.current
      const container = containerRef.current
      if (!content || !container || totalCols <= 1) return 0

      const spreadSize = spread ? 2 : 1
      const totalSpreads = Math.max(1, Math.ceil(totalCols / spreadSize))

      const paragraphs = Array.from(content.querySelectorAll<HTMLElement>('[data-offset]'))
      if (paragraphs.length === 0) return 0

      // Tìm đoạn văn chứa targetOffset
      let targetP: HTMLElement | null = null
      for (let i = paragraphs.length - 1; i >= 0; i--) {
        const off = Number(paragraphs[i].dataset.offset || 0)
        if (off <= targetOffset) {
          targetP = paragraphs[i]
          break
        }
      }
      if (!targetP) targetP = paragraphs[0]

      const pOffset = Number(targetP.dataset.offset || 0)
      const offsetInP = targetOffset - pOffset

      // Tìm text node cụ thể
      let foundNode: Node | null = null
      let nodeOffset = 0
      let currentLen = 0

      const walker = document.createTreeWalker(targetP, NodeFilter.SHOW_TEXT)
      let curr = walker.nextNode()
      while (curr) {
        const len = curr.textContent?.length || 0
        if (currentLen + len >= offsetInP) {
          foundNode = curr
          nodeOffset = Math.max(0, offsetInP - currentLen)
          break
        }
        currentLen += len
        curr = walker.nextNode()
      }

      if (foundNode) {
        try {
          const r = document.createRange()
          r.setStart(foundNode, nodeOffset)
          r.setEnd(foundNode, Math.min(nodeOffset + 1, foundNode.textContent?.length || nodeOffset))
          const rangeRect = r.getBoundingClientRect()
          const containerRect = container.getBoundingClientRect()

          // Toạ độ x không bị dịch bởi translateX hiện tại
          const currentSpread = spreadIndexRef.current
          const spreadWidth = spread ? (colWidth * 2 + colGap) : (colWidth + colGap)
          const untranslatedX = rangeRect.left - containerRect.left + currentSpread * spreadWidth

          const colIndex = Math.max(0, Math.floor(untranslatedX / (colWidth + colGap)))
          const foundSpread = Math.floor(colIndex / spreadSize)
          return Math.max(0, Math.min(totalSpreads - 1, foundSpread))
        } catch {
          // Bỏ qua nếu range lỗi
        }
      }

      // Fallback tính theo vị trí của thẻ P
      const pLeft = targetP.offsetLeft
      const colIndex = Math.max(0, Math.floor(pLeft / (colWidth + colGap)))
      const foundSpread = Math.floor(colIndex / spreadSize)
      return Math.max(0, Math.min(totalSpreads - 1, foundSpread))
    },
    [contentRef, containerRef],
  )

  // 5. Hàm đo lại và căn chỉnh trang
  const remeasure = useCallback(() => {
    const d = measureDimensions()
    const content = contentRef.current
    if (!d || !content) return

    setDims({ width: d.width, height: d.height, colWidth: d.colWidth, colGap: d.colGap })
    setIsSpread(d.spread)

    // Áp dụng CSS multi-column trực tiếp lên content element
    content.style.height = `${d.height}px`
    content.style.columnWidth = `${d.colWidth}px`
    content.style.columnGap = `${d.colGap}px`
    content.style.columnFill = 'auto'

    const scrollW = content.scrollWidth
    const pages = Math.max(1, Math.round((scrollW + d.colGap) / (d.colWidth + d.colGap)))
    setTotalPages(pages)

    const spreadSize = d.spread ? 2 : 1
    const totalSpreads = Math.max(1, Math.ceil(pages / spreadSize))

    // Định vị spread phù hợp
    let targetSpread = 0
    if (isInitialRestoreRef.current) {
      isInitialRestoreRef.current = false
      if (restoreOffset === 'end') {
        targetSpread = totalSpreads - 1
      } else if (typeof restoreOffset === 'number' && restoreOffset > 0) {
        targetSpread = findSpreadForOffset(restoreOffset, pages, d.spread, d.colWidth, d.colGap)
      }
    } else {
      // Giữ nguyên ký tự đang đọc khi resize / đổi font
      targetSpread = findSpreadForOffset(lastCharOffsetRef.current, pages, d.spread, d.colWidth, d.colGap)
    }

    targetSpread = Math.max(0, Math.min(totalSpreads - 1, targetSpread))
    setSpreadIndex(targetSpread)
    spreadIndexRef.current = targetSpread

    // Dịch translateX
    const spreadWidth = d.spread ? d.colWidth * 2 + d.colGap : d.colWidth + d.colGap
    content.style.transform = `translateX(-${targetSpread * spreadWidth}px)`

    // Cập nhật page range và báo cáo vị trí
    requestAnimationFrame(() => {
      const range = computePageRange()
      setPageRange(range)
      lastCharOffsetRef.current = range.start
      onReportPosition?.(range.start)
    })
  }, [measureDimensions, contentRef, restoreOffset, findSpreadForOffset, computePageRange, onReportPosition])

  // Lắng nghe resize và font load
  useLayoutEffect(() => {
    remeasure()

    const container = containerRef.current
    if (!container) return

    const ro = new ResizeObserver(() => {
      remeasure()
    })
    ro.observe(container)
    // Container bị maxWidth chặn nên có thể không đổi kích thước khi cửa sổ rộng ra
    if (container.parentElement) ro.observe(container.parentElement)

    if (typeof document !== 'undefined' && document.fonts) {
      void document.fonts.ready.then(() => remeasure())
    }

    return () => {
      ro.disconnect()
    }
  }, [remeasure, containerRef, text, chapterIndex])

  // Khi spreadIndex thay đổi -> dịch chuyển view và cập nhật vị trí
  useEffect(() => {
    spreadIndexRef.current = spreadIndex
    const content = contentRef.current
    if (!content) return

    const spreadWidth = isSpread ? dims.colWidth * 2 + dims.colGap : dims.colWidth + dims.colGap
    content.style.transform = `translateX(-${spreadIndex * spreadWidth}px)`

    const timer = setTimeout(() => {
      const range = computePageRange()
      setPageRange(range)
      lastCharOffsetRef.current = range.start
      onReportPosition?.(range.start)

      const spreadSize = isSpread ? 2 : 1
      const totalSpreads = Math.max(1, Math.ceil(totalPages / spreadSize))
      if (spreadIndex >= totalSpreads - 1 && isLastChapter) {
        onMarkFinished?.()
      }
    }, 100)

    return () => clearTimeout(timer)
  }, [spreadIndex, isSpread, dims, computePageRange, onReportPosition, totalPages, isLastChapter, onMarkFinished, contentRef])

  const spreadSize = isSpread ? 2 : 1
  const spreadCount = Math.max(1, Math.ceil(totalPages / spreadSize))

  const next = useCallback(() => {
    if (spreadIndex < spreadCount - 1) {
      setSpreadIndex((s) => s + 1)
    } else {
      onNextChapter()
    }
  }, [spreadIndex, spreadCount, onNextChapter])

  const prev = useCallback(() => {
    if (spreadIndex > 0) {
      setSpreadIndex((s) => s - 1)
    } else {
      onPrevChapter()
    }
  }, [spreadIndex, onPrevChapter])

  const goToOffset = useCallback(
    (offset: number) => {
      const targetSpread = findSpreadForOffset(offset, totalPages, isSpread, dims.colWidth, dims.colGap)
      setSpreadIndex(targetSpread)
    },
    [findSpreadForOffset, totalPages, isSpread, dims],
  )

  const currentPage = useMemo(() => {
    return isSpread ? Math.min(totalPages, spreadIndex * 2 + 1) : spreadIndex + 1
  }, [isSpread, totalPages, spreadIndex])

  return {
    page: currentPage,
    pageCount: totalPages,
    spread: isSpread,
    spreadIndex,
    spreadCount,
    pageRange,
    colWidth: dims.colWidth,
    colGap: dims.colGap,
    containerWidth: dims.width,
    containerHeight: dims.height,
    next,
    prev,
    goToOffset,
    remeasure,
  }
}
