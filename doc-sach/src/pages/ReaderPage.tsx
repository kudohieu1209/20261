import { useCallback, useEffect, useMemo, useRef, useState } from 'react'
import { Link, useParams } from 'react-router-dom'
import { useAnnotations } from '../hooks/useAnnotations'
import { useBookSearch } from '../hooks/useBookSearch'
import { usePageTurnControls } from '../hooks/usePageTurnControls'
import { usePaginator } from '../hooks/usePaginator'
import { useReader } from '../hooks/useReader'
import { useTts } from '../hooks/useTts'
import {
  segmentParagraph,
  selectionToRange,
  type HighlightRange,
  type TextSelectionRange,
} from '../lib/annotations'
import type { LocalNote } from '../lib/localDb'
import { useGlobalPageCount, type MeasureParams } from '../lib/pageCounts'

type TocTab = 'chapters' | 'bookmarks' | 'notes' | 'search'

const HIGHLIGHT_COLORS = [
  { id: 'yellow', name: 'Vàng', bg: 'var(--color-highlight-yellow)' },
  { id: 'amber', name: 'Cam nhạt', bg: 'var(--color-highlight-amber)' },
  { id: 'gray', name: 'Xám', bg: 'var(--color-highlight-gray)' },
  { id: 'slate', name: 'Xám đá', bg: 'var(--color-highlight-slate)' },
]

export default function ReaderPage() {
  const { bookId = '' } = useParams()
  const r = useReader(bookId)
  const annotations = useAnnotations(r.book?.id)

  const [tocOpen, setTocOpen] = useState(false)
  const [tocTab, setTocTab] = useState<TocTab>('chapters')
  const [toolbarOpen, setToolbarOpen] = useState(false)

  // Tìm kiếm toàn văn
  const search = useBookSearch(r.book?.id)
  const [searchHit, setSearchHit] = useState<{ chapterIndex: number; start: number; end: number } | null>(null)

  // Đọc to TTS
  const [ttsBarOpen, setTtsBarOpen] = useState(false)

  // Thanh chọn chữ (Highlight / Ghi chú)
  const [selectedRange, setSelectedRange] = useState<TextSelectionRange | null>(null)
  const [selectionRect, setSelectionRect] = useState<{ top: number; left: number } | null>(null)
  const [noteModalOpen, setNoteModalOpen] = useState(false)
  const [noteInputText, setNoteInputText] = useState('')
  const [activeNote, setActiveNote] = useState<LocalNote | null>(null)

  const containerRef = useRef<HTMLDivElement>(null)
  const contentRef = useRef<HTMLElement>(null)

  const paginator = usePaginator({
    containerRef,
    contentRef,
    text: r.chapter ? r.paragraphs.map((p) => p.text).join('\n') : '',
    chapterIndex: r.chapter?.index ?? 0,
    restoreOffset: r.restoreOffset,
    isLastChapter: r.isLastChapter,
    onNextChapter: r.nextChapter,
    onPrevChapter: r.prevChapter,
    onReportPosition: r.reportPosition,
    onMarkFinished: r.markFinished,
  })

  // Đọc to bằng giọng nói tiếng Việt
  const tts = useTts(r, paginator)

  // Điều khiển lật trang
  usePageTurnControls({
    containerRef,
    onNext: paginator.next,
    onPrev: paginator.prev,
    onToggleToolbar: () => setToolbarOpen((v) => !v),
  })

  // Đếm trang toàn sách ở nền
  const measureParams: MeasureParams | null = useMemo(() => {
    if (paginator.containerWidth <= 0 || paginator.containerHeight <= 0) return null
    return {
      width: paginator.containerWidth,
      height: paginator.containerHeight,
      colWidth: paginator.colWidth,
      colGap: paginator.colGap,
      fontFamily: 'var(--font-book)',
      fontSize: 'var(--book-font-size)',
      lineHeight: 1.6,
      isSpread: paginator.spread,
    }
  }, [paginator.containerWidth, paginator.containerHeight, paginator.colWidth, paginator.colGap, paginator.spread])

  const { globalPage, totalPages, isComplete } = useGlobalPageCount(
    r.book?.id,
    r.toc?.chapters,
    measureParams,
    r.chapter?.index ?? 0,
    paginator.page,
  )

  // ── Lắng nghe bôi đen chữ để hiện thanh menu công cụ ────────────────────
  useEffect(() => {
    const handleSelection = () => {
      const root = contentRef.current
      if (!root) return

      const sel = window.getSelection()
      if (!sel || sel.isCollapsed || !sel.toString().trim()) {
        setSelectedRange(null)
        setSelectionRect(null)
        return
      }

      const res = selectionToRange(root)
      if (res) {
        setSelectedRange(res)
        const range = sel.getRangeAt(0)
        const rect = range.getBoundingClientRect()
        setSelectionRect({
          top: Math.max(10, rect.top - 54),
          left: Math.max(10, Math.min(window.innerWidth - 220, rect.left + rect.width / 2 - 110)),
        })
      }
    }

    document.addEventListener('selectionchange', handleSelection)
    return () => {
      document.removeEventListener('selectionchange', handleSelection)
    }
  }, [])

  // Tạo highlight nhanh
  const handleCreateHighlight = useCallback(
    async (colorId: string) => {
      if (!selectedRange || !r.chapter) return
      await annotations.createNote({
        chapterIndex: r.chapter.index,
        charStart: selectedRange.start,
        charEnd: selectedRange.end,
        quote: selectedRange.quote,
        color: colorId,
      })
      window.getSelection()?.removeAllRanges()
      setSelectedRange(null)
      setSelectionRect(null)
    },
    [selectedRange, r.chapter, annotations],
  )

  // Mở modal thêm ghi chú cho vùng bôi đen
  const handleOpenAddNote = useCallback(() => {
    if (!selectedRange) return
    setActiveNote(null)
    setNoteInputText('')
    setNoteModalOpen(true)
    setSelectionRect(null)
  }, [selectedRange])

  // Lưu ghi chú
  const handleSaveNote = useCallback(async () => {
    if (!r.chapter) return
    if (activeNote) {
      await annotations.editNote(activeNote.id, { content: noteInputText })
    } else if (selectedRange) {
      await annotations.createNote({
        chapterIndex: r.chapter.index,
        charStart: selectedRange.start,
        charEnd: selectedRange.end,
        quote: selectedRange.quote,
        color: 'yellow',
        content: noteInputText,
      })
      window.getSelection()?.removeAllRanges()
      setSelectedRange(null)
    }
    setNoteModalOpen(false)
    setActiveNote(null)
    setNoteInputText('')
  }, [activeNote, selectedRange, r.chapter, annotations, noteInputText])

  // Sao chép văn bản
  const handleCopySelection = useCallback(() => {
    if (!selectedRange) return
    void navigator.clipboard.writeText(selectedRange.quote)
    window.getSelection()?.removeAllRanges()
    setSelectedRange(null)
    setSelectionRect(null)
  }, [selectedRange])

  // Kiểm tra trang hiện tại có dấu trang hay không
  const currentBookmark = useMemo(() => {
    if (!r.chapter) return null
    return annotations.isBookmarked(paginator.pageRange, r.chapter.index)
  }, [annotations, paginator.pageRange, r.chapter])

  // Tập hợp các highlight trong chương hiện tại
  const chapterHighlights: HighlightRange[] = useMemo(() => {
    if (!r.chapter) return []
    const notes = annotations.notesForChapter(r.chapter.index)
    const list: HighlightRange[] = notes.map((n) => ({
      start: n.char_start,
      end: n.char_end,
      noteId: n.id,
      color: n.color,
      content: n.content,
    }))
    if (searchHit && searchHit.chapterIndex === r.chapter.index) {
      list.push({
        start: searchHit.start,
        end: searchHit.end,
        isSearchHit: true,
      })
    }
    if (tts.playing && tts.current) {
      list.push({
        start: tts.current.start,
        end: tts.current.end,
        ttsActive: true,
      })
    }
    return list
  }, [annotations, r.chapter, searchHit, tts])

  if (r.error) return <div style={{ padding: '2rem', color: 'var(--color-danger)' }} role="alert">{r.error}</div>
  if (r.loading || !r.book || !r.toc || !r.chapter) {
    return (
      <div style={{ display: 'flex', alignItems: 'center', justifyContent: 'center', height: '100vh', color: 'var(--color-text-secondary)' }}>
        <p className="apple-fade-in">Đang mở sách…</p>
      </div>
    )
  }

  const volume = r.chapter.volumeIndex !== null ? r.toc.volumes[r.chapter.volumeIndex] : null

  return (
    <div
      style={{
        position: 'fixed',
        inset: 0,
        backgroundColor: 'var(--color-bg)',
        color: 'var(--color-page-text)',
        display: 'flex',
        flexDirection: 'column',
        overflow: 'hidden',
        userSelect: 'none',
      }}
    >
      {/* ── Nút Ruy Băng Dấu Trang ở góc trên phải trang sách ── */}
      <button
        onClick={() => {
          if (r.chapter) {
            void annotations.toggleBookmark(paginator.pageRange, r.chapter.index)
          }
        }}
        title={currentBookmark ? 'Bỏ dấu trang' : 'Đánh dấu trang này'}
        style={{
          position: 'absolute',
          top: 0,
          right: '32px',
          zIndex: 35,
          background: 'none',
          border: 'none',
          cursor: 'pointer',
          padding: '8px 4px 12px',
          color: currentBookmark ? 'var(--color-danger)' : 'var(--color-text-tertiary)',
          opacity: currentBookmark || toolbarOpen ? 1 : 0.2,
          transition: 'color var(--duration-fast) var(--ease-apple), opacity var(--duration-fast) var(--ease-apple)',
        }}
      >
        <svg width="24" height="28" viewBox="0 0 24 28" fill={currentBookmark ? 'currentColor' : 'none'} stroke="currentColor" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round">
          <path d="M19 21l-7-5-7 5V5a2 2 0 0 1 2-2h10a2 2 0 0 1 2 2z" />
        </svg>
      </button>

      {/* ── Thanh công cụ trên (Apple Glass Floating Bar) ── */}
      <header
        style={{
          position: 'absolute',
          top: 0,
          left: 0,
          right: 0,
          height: '56px',
          padding: '0 var(--space-4)',
          display: 'flex',
          alignItems: 'center',
          justifyContent: 'space-between',
          background: 'var(--glass-bg)',
          backdropFilter: 'var(--glass-blur)',
          WebkitBackdropFilter: 'var(--glass-blur)',
          borderBottom: '1px solid var(--color-border)',
          zIndex: 40,
          transform: toolbarOpen ? 'translateY(0)' : 'translateY(-100%)',
          opacity: toolbarOpen ? 1 : 0,
          pointerEvents: toolbarOpen ? 'auto' : 'none',
          transition: 'transform var(--duration-fast) var(--ease-apple), opacity var(--duration-fast) var(--ease-apple)',
        }}
      >
        <Link
          to="/"
          style={{
            display: 'inline-flex',
            alignItems: 'center',
            gap: 'var(--space-1)',
            color: 'var(--color-text)',
            textDecoration: 'none',
            fontSize: 'var(--text-sm)',
            fontWeight: 500,
            padding: '6px 12px',
            borderRadius: 'var(--radius-md)',
            background: 'var(--color-surface)',
          }}
        >
          ‹ Thư viện
        </Link>

        <div style={{ textAlign: 'center', overflow: 'hidden', textOverflow: 'ellipsis', whiteSpace: 'nowrap', maxWidth: '45%' }}>
          <span style={{ fontSize: 'var(--text-sm)', fontWeight: 600 }}>{r.book.title}</span>
          <span style={{ fontSize: 'var(--text-xs)', color: 'var(--color-text-secondary)', marginLeft: '8px' }}>
            {r.chapter.label}
          </span>
        </div>

        <div style={{ display: 'flex', alignItems: 'center', gap: 'var(--space-2)' }}>
          {tts.supported && (
            <button
              onClick={() => {
                setTtsBarOpen((v) => !v)
                if (!tts.playing) {
                  tts.play()
                }
              }}
              style={{
                padding: '6px 12px',
                borderRadius: 'var(--radius-md)',
                background: tts.playing ? 'var(--color-accent)' : 'var(--color-surface)',
                color: tts.playing ? 'var(--color-on-accent)' : 'var(--color-text)',
                border: 'none',
                fontSize: 'var(--text-sm)',
                fontWeight: 500,
                cursor: 'pointer',
              }}
            >
              {tts.playing ? '■ Dừng đọc' : '▶ Đọc to'}
            </button>
          )}

          <button
            onClick={() => {
              setTocTab('chapters')
              setTocOpen(true)
            }}
            style={{
              padding: '6px 12px',
              borderRadius: 'var(--radius-md)',
              background: 'var(--color-surface)',
              border: 'none',
              fontSize: 'var(--text-sm)',
              fontWeight: 500,
              cursor: 'pointer',
            }}
          >
            Mục lục
          </button>
        </div>
      </header>

      {/* ── Thanh điều khiển Đọc to (TTS Floating Player) ── */}
      {(ttsBarOpen || tts.playing) && tts.supported && (
        <div
          className="apple-sheet"
          style={{
            position: 'absolute',
            top: '64px',
            left: '50%',
            transform: 'translateX(-50%)',
            zIndex: 45,
            display: 'flex',
            alignItems: 'center',
            gap: 'var(--space-3)',
            padding: '8px 16px',
            background: 'var(--glass-bg)',
            backdropFilter: 'var(--glass-blur)',
            WebkitBackdropFilter: 'var(--glass-blur)',
            borderRadius: 'var(--radius-full)',
            boxShadow: 'var(--shadow-md)',
            border: '1px solid var(--color-border)',
          }}
        >
          <button
            onClick={() => (tts.playing ? tts.pause() : tts.play())}
            style={{
              padding: '6px 12px',
              borderRadius: 'var(--radius-full)',
              background: 'var(--color-accent)',
              color: 'var(--color-on-accent)',
              border: 'none',
              fontSize: 'var(--text-xs)',
              fontWeight: 600,
              cursor: 'pointer',
            }}
          >
            {tts.playing ? 'Tạm dừng' : 'Tiếp tục'}
          </button>

          <button
            onClick={tts.stop}
            style={{
              background: 'none',
              border: 'none',
              color: 'var(--color-text-secondary)',
              fontSize: 'var(--text-xs)',
              cursor: 'pointer',
              padding: '4px',
            }}
          >
            Dừng
          </button>

          {/* Tốc độ đọc */}
          <div style={{ display: 'flex', alignItems: 'center', gap: '4px' }}>
            {[0.8, 1.0, 1.2, 1.5].map((speed) => (
              <button
                key={speed}
                onClick={() => tts.setRate(speed)}
                style={{
                  background: tts.rate === speed ? 'var(--color-surface)' : 'transparent',
                  border: 'none',
                  borderRadius: 'var(--radius-sm)',
                  padding: '2px 6px',
                  fontSize: '11px',
                  fontWeight: tts.rate === speed ? 700 : 400,
                  cursor: 'pointer',
                  color: 'inherit',
                }}
              >
                {speed}x
              </button>
            ))}
          </div>

          {/* Chọn giọng nếu có nhiều giọng */}
          {tts.voices.length > 1 && (
            <select
              value={tts.voice?.voiceURI || ''}
              onChange={(e) => {
                const found = tts.voices.find((v) => v.voiceURI === e.target.value)
                if (found) tts.setVoice(found)
              }}
              style={{
                fontSize: '11px',
                padding: '2px 6px',
                borderRadius: 'var(--radius-sm)',
                border: '1px solid var(--color-border)',
                background: 'transparent',
                outline: 'none',
                maxWidth: '120px',
              }}
            >
              {tts.voices.map((v) => (
                <option key={v.voiceURI} value={v.voiceURI}>
                  {v.name}
                </option>
              ))}
            </select>
          )}

          <button
            onClick={() => setTtsBarOpen(false)}
            style={{
              background: 'none',
              border: 'none',
              color: 'var(--color-text-tertiary)',
              cursor: 'pointer',
              padding: '2px 4px',
              fontSize: '12px',
            }}
          >
            ✕
          </button>
        </div>
      )}

      {/* ── Khung nhìn trang sách (Lật 1 hoặc 2 trang) ── */}
      <main
        ref={containerRef}
        style={{
          position: 'relative',
          flex: 1,
          margin: '0 auto',
          width: '100%',
          maxWidth: paginator.spread ? '1200px' : '720px',
          padding: '40px 24px 32px',
          overflow: 'hidden',
          boxSizing: 'border-box',
          userSelect: 'text',
        }}
      >
        {/* Đường gáy sách ở giữa khi ở chế độ 2 trang */}
        {paginator.spread && (
          <div
            style={{
              position: 'absolute',
              top: '40px',
              bottom: '32px',
              left: '50%',
              width: '1px',
              background: 'var(--color-page-gutter)',
              boxShadow: '0 0 16px rgba(0, 0, 0, 0.05)',
              zIndex: 10,
              pointerEvents: 'none',
            }}
          />
        )}

        <article
          ref={contentRef}
          style={{
            fontFamily: 'var(--font-book)',
            fontSize: 'var(--book-font-size)',
            lineHeight: 'var(--book-line-height)',
            color: 'var(--color-page-text)',
            height: '100%',
            overflow: 'visible',
            willChange: 'transform',
            transition: 'transform var(--duration-page-turn) var(--ease-apple)',
          }}
        >
          {volume && (
            <p style={{ color: 'var(--color-page-muted)', fontSize: '0.9em', margin: '0 0 0.5em 0' }}>
              {volume.label}{volume.title && `: ${volume.title}`}
            </p>
          )}

          <h2 style={{ fontSize: '1.25em', fontWeight: 600, margin: '0 0 0.25em 0', color: 'var(--color-page-text)' }}>
            {r.chapter.label}
          </h2>

          {r.chapter.title && (
            <h1 style={{ fontSize: '1.45em', fontWeight: 700, margin: '0 0 0.5em 0', color: 'var(--color-page-text)' }}>
              {r.chapter.title}
            </h1>
          )}

          {r.chapter.originalTitle && (
            <p lang="zh" style={{ color: 'var(--color-page-muted)', margin: '0 0 1em 0' }}>
              {r.chapter.originalTitle}
            </p>
          )}

          {r.paragraphs.map((p) => {
            const segments = segmentParagraph(p, chapterHighlights)
            return (
              <p
                key={p.start}
                data-offset={p.start}
                style={{
                  margin: '0 0 0.6em 0',
                  textIndent: 'var(--book-paragraph-indent)',
                  textAlign: 'justify',
                  wordBreak: 'break-word',
                }}
              >
                {segments.map((seg, idx) => {
                  if (seg.ttsActive || seg.isSearchHit) {
                    return (
                      <mark
                        key={idx}
                        style={{
                          backgroundColor: 'var(--color-highlight-active)',
                          borderRadius: '2px',
                          padding: '0 2px',
                          color: 'inherit',
                        }}
                      >
                        {seg.text}
                      </mark>
                    )
                  }
                  if (seg.color) {
                    const colorDef = HIGHLIGHT_COLORS.find((c) => c.id === seg.color)?.bg || 'var(--color-highlight-yellow)'
                    return (
                      <mark
                        key={idx}
                        onClick={(e) => {
                          e.stopPropagation()
                          if (seg.noteId) {
                            const n = annotations.notes.find((item) => item.id === seg.noteId)
                            if (n) {
                              setActiveNote(n)
                              setNoteInputText(n.content || '')
                              setNoteModalOpen(true)
                            }
                          }
                        }}
                        style={{
                          backgroundColor: colorDef,
                          borderRadius: '2px',
                          cursor: 'pointer',
                          padding: '0 1px',
                          color: 'inherit',
                        }}
                      >
                        {seg.text}
                      </mark>
                    )
                  }
                  return <span key={idx}>{seg.text}</span>
                })}
              </p>
            )
          })}
        </article>
      </main>

      {/* ── Menu nổi khi bôi đen chữ (Floating Selection Popover) ── */}
      {selectionRect && selectedRange && (
        <div
          className="apple-fade-in"
          style={{
            position: 'fixed',
            top: `${selectionRect.top}px`,
            left: `${selectionRect.left}px`,
            zIndex: 60,
            display: 'flex',
            alignItems: 'center',
            gap: 'var(--space-1)',
            padding: '4px 8px',
            backgroundColor: 'var(--color-text)',
            color: 'var(--color-on-accent)',
            borderRadius: 'var(--radius-full)',
            boxShadow: 'var(--shadow-md)',
          }}
          onPointerDown={(e) => e.stopPropagation()}
        >
          {/* 4 màu Highlight */}
          {HIGHLIGHT_COLORS.map((c) => (
            <button
              key={c.id}
              onClick={() => void handleCreateHighlight(c.id)}
              title={`Tô sáng ${c.name}`}
              style={{
                width: '20px',
                height: '20px',
                borderRadius: '50%',
                backgroundColor: c.bg,
                border: '2px solid rgba(255,255,255,0.7)',
                cursor: 'pointer',
                padding: 0,
              }}
            />
          ))}

          <div style={{ width: '1px', height: '16px', background: 'rgba(255,255,255,0.2)', margin: '0 4px' }} />

          <button
            onClick={handleOpenAddNote}
            style={{
              background: 'none',
              border: 'none',
              color: 'inherit',
              fontSize: 'var(--text-xs)',
              fontWeight: 500,
              cursor: 'pointer',
              padding: '4px 6px',
            }}
          >
            Ghi chú
          </button>

          <button
            onClick={handleCopySelection}
            style={{
              background: 'none',
              border: 'none',
              color: 'inherit',
              fontSize: 'var(--text-xs)',
              fontWeight: 500,
              cursor: 'pointer',
              padding: '4px 6px',
            }}
          >
            Sao chép
          </button>
        </div>
      )}

      {/* ── Footer hiển thị trang và tiến độ đọc ── */}
      <footer
        style={{
          height: '36px',
          padding: '0 var(--space-4)',
          display: 'flex',
          alignItems: 'center',
          justifyContent: 'space-between',
          fontSize: 'var(--text-xs)',
          color: 'var(--color-page-muted)',
          zIndex: 20,
        }}
      >
        <div style={{ display: 'flex', alignItems: 'center', gap: 'var(--space-2)' }}>
          <button
            onClick={paginator.prev}
            disabled={r.chapter.index === 0 && paginator.spreadIndex === 0}
            style={{
              background: 'none',
              border: 'none',
              color: 'inherit',
              cursor: 'pointer',
              padding: '4px 8px',
              borderRadius: 'var(--radius-sm)',
              opacity: r.chapter.index === 0 && paginator.spreadIndex === 0 ? 0.3 : 1,
            }}
          >
            ‹ Trước
          </button>
        </div>

        <div>
          {isComplete && globalPage && totalPages ? (
            <span>Trang {globalPage} / {totalPages} · {r.chapter.label} ({paginator.page}/{paginator.pageCount})</span>
          ) : (
            <span>{r.chapter.label} · Trang {paginator.page}/{paginator.pageCount} · {(r.percent * 100).toFixed(1)}%</span>
          )}
        </div>

        <div style={{ display: 'flex', alignItems: 'center', gap: 'var(--space-2)' }}>
          <button
            onClick={paginator.next}
            disabled={r.isLastChapter && paginator.spreadIndex >= paginator.spreadCount - 1}
            style={{
              background: 'none',
              border: 'none',
              color: 'inherit',
              cursor: 'pointer',
              padding: '4px 8px',
              borderRadius: 'var(--radius-sm)',
              opacity: r.isLastChapter && paginator.spreadIndex >= paginator.spreadCount - 1 ? 0.3 : 1,
            }}
          >
            Sau ›
          </button>
        </div>
      </footer>

      {/* ── Modal Soạn Ghi Chú Phong Cách Apple ── */}
      {noteModalOpen && (
        <div
          style={{
            position: 'fixed',
            inset: 0,
            backgroundColor: 'var(--color-scrim)',
            backdropFilter: 'blur(4px)',
            WebkitBackdropFilter: 'blur(4px)',
            zIndex: 70,
            display: 'flex',
            alignItems: 'center',
            justifyContent: 'center',
            padding: 'var(--space-4)',
          }}
          onClick={() => setNoteModalOpen(false)}
        >
          <div
            className="apple-sheet"
            onClick={(e) => e.stopPropagation()}
            style={{
              width: '100%',
              maxWidth: '440px',
              backgroundColor: 'var(--color-surface-raised)',
              borderRadius: 'var(--radius-lg)',
              boxShadow: 'var(--shadow-lg)',
              padding: 'var(--space-5)',
              display: 'flex',
              flexDirection: 'column',
              gap: 'var(--space-3)',
            }}
          >
            <h3 style={{ margin: 0, fontSize: 'var(--text-base)', fontWeight: 600 }}>
              {activeNote ? 'Chỉnh sửa ghi chú' : 'Thêm ghi chú mới'}
            </h3>

            {/* Trích dẫn */}
            <p
              style={{
                margin: 0,
                fontSize: 'var(--text-xs)',
                color: 'var(--color-text-secondary)',
                fontStyle: 'italic',
                borderLeft: '2px solid var(--color-border-strong)',
                paddingLeft: '8px',
                maxHeight: '60px',
                overflow: 'hidden',
                textOverflow: 'ellipsis',
              }}
            >
              "{activeNote?.quote || selectedRange?.quote}"
            </p>

            <textarea
              autoFocus
              value={noteInputText}
              onChange={(e) => setNoteInputText(e.target.value)}
              placeholder="Nhập nội dung ghi chú của bạn…"
              rows={4}
              style={{
                width: '100%',
                padding: 'var(--space-3)',
                borderRadius: 'var(--radius-md)',
                border: '1px solid var(--color-border)',
                background: 'var(--color-surface)',
                fontFamily: 'inherit',
                fontSize: 'var(--text-sm)',
                resize: 'none',
                boxSizing: 'border-box',
                outline: 'none',
              }}
            />

            <div style={{ display: 'flex', alignItems: 'center', justifyContent: 'space-between', marginTop: 'var(--space-2)' }}>
              {activeNote ? (
                <button
                  onClick={async () => {
                    await annotations.deleteNote(activeNote.id)
                    setNoteModalOpen(false)
                    setActiveNote(null)
                  }}
                  style={{
                    background: 'none',
                    border: 'none',
                    color: 'var(--color-danger)',
                    fontSize: 'var(--text-sm)',
                    cursor: 'pointer',
                    padding: '6px 8px',
                  }}
                >
                  Xoá ghi chú
                </button>
              ) : <div />}

              <div style={{ display: 'flex', gap: 'var(--space-2)' }}>
                <button
                  onClick={() => setNoteModalOpen(false)}
                  style={{
                    padding: '8px 14px',
                    borderRadius: 'var(--radius-md)',
                    border: '1px solid var(--color-border)',
                    background: 'transparent',
                    fontSize: 'var(--text-sm)',
                    cursor: 'pointer',
                  }}
                >
                  Huỷ
                </button>
                <button
                  onClick={handleSaveNote}
                  style={{
                    padding: '8px 16px',
                    borderRadius: 'var(--radius-md)',
                    border: 'none',
                    background: 'var(--color-accent)',
                    color: 'var(--color-on-accent)',
                    fontSize: 'var(--text-sm)',
                    fontWeight: 500,
                    cursor: 'pointer',
                  }}
                >
                  Lưu
                </button>
              </div>
            </div>
          </div>
        </div>
      )}

      {/* ── Modal / Sheet Mục lục & Dấu trang & Ghi chú phong cách Apple ── */}
      {tocOpen && (
        <div
          style={{
            position: 'fixed',
            inset: 0,
            backgroundColor: 'var(--color-scrim)',
            backdropFilter: 'blur(4px)',
            WebkitBackdropFilter: 'blur(4px)',
            zIndex: 50,
            display: 'flex',
            justifyContent: 'flex-end',
          }}
          onClick={() => setTocOpen(false)}
        >
          <aside
            className="apple-sheet"
            onClick={(e) => e.stopPropagation()}
            style={{
              width: '100%',
              maxWidth: '400px',
              height: '100%',
              backgroundColor: 'var(--color-surface-raised)',
              boxShadow: 'var(--shadow-lg)',
              display: 'flex',
              flexDirection: 'column',
              overflow: 'hidden',
            }}
          >
            {/* Header Tabs */}
            <div style={{ padding: 'var(--space-3) var(--space-4)', borderBottom: '1px solid var(--color-border)' }}>
              <div style={{ display: 'flex', alignItems: 'center', justifyContent: 'space-between', marginBottom: 'var(--space-3)' }}>
                <h3 style={{ margin: 0, fontSize: 'var(--text-lg)', fontWeight: 600 }}>Nội dung</h3>
                <button
                  onClick={() => setTocOpen(false)}
                  style={{
                    background: 'none',
                    border: 'none',
                    fontSize: 'var(--text-lg)',
                    cursor: 'pointer',
                    color: 'var(--color-text-secondary)',
                  }}
                >
                  ✕
                </button>
              </div>

              {/* 3 Tabs: Mục lục, Dấu trang, Ghi chú */}
              <div
                style={{
                  display: 'flex',
                  backgroundColor: 'var(--color-surface)',
                  padding: '3px',
                  borderRadius: 'var(--radius-md)',
                  gap: '2px',
                }}
              >
                {(
                  [
                    { id: 'chapters', label: 'Chương' },
                    { id: 'bookmarks', label: `Dấu trang (${annotations.bookmarks.length})` },
                    { id: 'notes', label: `Ghi chú (${annotations.notes.length})` },
                    { id: 'search', label: 'Tìm' },
                  ] as const
                ).map((t) => (
                  <button
                    key={t.id}
                    onClick={() => setTocTab(t.id)}
                    style={{
                      flex: 1,
                      padding: '6px 8px',
                      borderRadius: 'calc(var(--radius-md) - 2px)',
                      border: 'none',
                      background: tocTab === t.id ? 'var(--color-surface-raised)' : 'transparent',
                      color: tocTab === t.id ? 'var(--color-text)' : 'var(--color-text-secondary)',
                      boxShadow: tocTab === t.id ? 'var(--shadow-sm)' : 'none',
                      fontSize: 'var(--text-xs)',
                      fontWeight: tocTab === t.id ? 600 : 500,
                      cursor: 'pointer',
                    }}
                  >
                    {t.label}
                  </button>
                ))}
              </div>
            </div>

            {/* Tab Content */}
            <div style={{ flex: 1, overflowY: 'auto', padding: 'var(--space-2)' }}>
              {/* Tab 1: Mục lục chương */}
              {tocTab === 'chapters' && (
                <ol style={{ margin: 0, padding: 0, listStyle: 'none' }}>
                  {r.toc.chapters.map((c) => {
                    const isActive = c.index === r.chapter!.index
                    return (
                      <li key={c.index} style={{ marginBottom: '2px' }}>
                        <button
                          onClick={() => {
                            r.goToChapter(c.index, 0)
                            setTocOpen(false)
                          }}
                          style={{
                            width: '100%',
                            textAlign: 'left',
                            padding: '10px 14px',
                            borderRadius: 'var(--radius-md)',
                            background: isActive ? 'var(--color-surface)' : 'transparent',
                            border: 'none',
                            color: isActive ? 'var(--color-accent)' : 'var(--color-text)',
                            fontWeight: isActive ? 600 : 400,
                            fontSize: 'var(--text-sm)',
                            cursor: 'pointer',
                            display: 'flex',
                            flexDirection: 'column',
                            gap: '2px',
                          }}
                        >
                          <span>{c.label}</span>
                          {c.title && (
                            <span style={{ fontSize: 'var(--text-xs)', color: 'var(--color-text-secondary)' }}>
                              {c.title}
                            </span>
                          )}
                        </button>
                      </li>
                    )
                  })}
                </ol>
              )}

              {/* Tab 2: Danh sách Dấu trang */}
              {tocTab === 'bookmarks' && (
                <div>
                  {annotations.bookmarks.length === 0 ? (
                    <p style={{ textAlign: 'center', color: 'var(--color-text-tertiary)', padding: '2rem 1rem', fontSize: 'var(--text-sm)' }}>
                      Chưa có dấu trang nào. Chạm vào ruy băng góc trên phải để đánh dấu trang bạn thích.
                    </p>
                  ) : (
                    <ul style={{ margin: 0, padding: 0, listStyle: 'none' }}>
                      {annotations.bookmarks.map((b) => {
                        const ch = r.toc!.chapters[b.chapter_index]
                        return (
                          <li
                            key={b.id}
                            style={{
                              padding: '10px 12px',
                              borderRadius: 'var(--radius-md)',
                              background: 'var(--color-surface)',
                              marginBottom: 'var(--space-2)',
                              display: 'flex',
                              alignItems: 'center',
                              justifyContent: 'space-between',
                            }}
                          >
                            <div
                              onClick={() => {
                                r.goToChapter(b.chapter_index, b.char_offset)
                                setTocOpen(false)
                              }}
                              style={{ flex: 1, cursor: 'pointer' }}
                            >
                              <div style={{ fontSize: 'var(--text-sm)', fontWeight: 600 }}>
                                {ch?.label || `Chương ${b.chapter_index + 1}`}
                              </div>
                              <div style={{ fontSize: 'var(--text-xs)', color: 'var(--color-text-secondary)' }}>
                                {b.label || `Vị trí ký tự ${b.char_offset}`}
                              </div>
                            </div>
                            <button
                              onClick={() => void annotations.deleteBookmark(b.id)}
                              style={{
                                background: 'none',
                                border: 'none',
                                color: 'var(--color-text-tertiary)',
                                cursor: 'pointer',
                                padding: '4px',
                              }}
                            >
                              ✕
                            </button>
                          </li>
                        )
                      })}
                    </ul>
                  )}
                </div>
              )}

              {/* Tab 3: Danh sách Ghi chú & Highlight */}
              {tocTab === 'notes' && (
                <div>
                  {annotations.notes.length === 0 ? (
                    <p style={{ textAlign: 'center', color: 'var(--color-text-tertiary)', padding: '2rem 1rem', fontSize: 'var(--text-sm)' }}>
                      Chưa có ghi chú nào. Bôi đen văn bản trong sách để tô màu hoặc ghi chú.
                    </p>
                  ) : (
                    <ul style={{ margin: 0, padding: 0, listStyle: 'none' }}>
                      {annotations.notes.map((n) => {
                        const ch = r.toc!.chapters[n.chapter_index]
                        const colorDef = HIGHLIGHT_COLORS.find((c) => c.id === n.color)?.bg || 'var(--color-highlight-yellow)'
                        return (
                          <li
                            key={n.id}
                            style={{
                              padding: '12px',
                              borderRadius: 'var(--radius-md)',
                              background: 'var(--color-surface)',
                              marginBottom: 'var(--space-2)',
                              borderLeft: `4px solid ${colorDef}`,
                            }}
                          >
                            <div
                              onClick={() => {
                                r.goToChapter(n.chapter_index, n.char_start)
                                setTocOpen(false)
                              }}
                              style={{ cursor: 'pointer' }}
                            >
                              <div style={{ fontSize: 'var(--text-xs)', color: 'var(--color-text-secondary)', marginBottom: '4px' }}>
                                {ch?.label || `Chương ${n.chapter_index + 1}`}
                              </div>
                              <div style={{ fontSize: 'var(--text-sm)', fontStyle: 'italic', marginBottom: '6px' }}>
                                "{n.quote}"
                              </div>
                              {n.content && (
                                <div style={{ fontSize: 'var(--text-sm)', fontWeight: 500, color: 'var(--color-text)' }}>
                                  {n.content}
                                </div>
                              )}
                            </div>
                            <div style={{ display: 'flex', justifyContent: 'flex-end', gap: 'var(--space-2)', marginTop: '6px' }}>
                              <button
                                onClick={() => {
                                  setActiveNote(n)
                                  setNoteInputText(n.content || '')
                                  setNoteModalOpen(true)
                                }}
                                style={{
                                  background: 'none',
                                  border: 'none',
                                  fontSize: 'var(--text-xs)',
                                  color: 'var(--color-text-secondary)',
                                  cursor: 'pointer',
                                }}
                              >
                                Sửa
                              </button>
                              <button
                                onClick={() => void annotations.deleteNote(n.id)}
                                style={{
                                  background: 'none',
                                  border: 'none',
                                  fontSize: 'var(--text-xs)',
                                  color: 'var(--color-danger)',
                                  cursor: 'pointer',
                                }}
                              >
                                Xoá
                              </button>
                            </div>
                          </li>
                        )
                      })}
                    </ul>
                  )}
                </div>
              )}

              {/* Tab 4: Tìm kiếm toàn văn trong cả sách */}
              {tocTab === 'search' && (
                <div>
                  <div style={{ marginBottom: 'var(--space-3)' }}>
                    <input
                      type="search"
                      value={search.query}
                      onChange={(e) => search.setQuery(e.target.value)}
                      placeholder="Tìm trong cả sách (gõ không dấu)..."
                      style={{
                        width: '100%',
                        padding: '10px 14px',
                        borderRadius: 'var(--radius-md)',
                        border: '1px solid var(--color-border)',
                        background: 'var(--color-surface)',
                        fontSize: 'var(--text-sm)',
                        boxSizing: 'border-box',
                        outline: 'none',
                      }}
                    />
                    {search.searching && (
                      <div style={{ fontSize: 'var(--text-xs)', color: 'var(--color-text-secondary)', marginTop: '6px' }}>
                        Đang quét dữ liệu sách…
                      </div>
                    )}
                    {!search.searching && search.query.trim() && (
                      <div style={{ fontSize: 'var(--text-xs)', color: 'var(--color-text-secondary)', marginTop: '6px' }}>
                        Tìm thấy {search.total} kết quả
                      </div>
                    )}
                  </div>

                  {search.results.length === 0 && !search.searching && search.query.trim() && (
                    <p style={{ textAlign: 'center', color: 'var(--color-text-tertiary)', padding: '2rem 1rem', fontSize: 'var(--text-sm)' }}>
                      Không tìm thấy kết quả nào phù hợp.
                    </p>
                  )}

                  <ul style={{ margin: 0, padding: 0, listStyle: 'none' }}>
                    {search.results.map((item, idx) => {
                      const ch = r.toc!.chapters[item.chapterIndex]
                      return (
                        <li
                          key={idx}
                          onClick={() => {
                            setSearchHit({ chapterIndex: item.chapterIndex, start: item.offset, end: item.offset + item.length })
                            r.goToChapter(item.chapterIndex, item.offset)
                            setTocOpen(false)
                            setTimeout(() => setSearchHit(null), 5000)
                          }}
                          style={{
                            padding: '10px 12px',
                            borderRadius: 'var(--radius-md)',
                            background: 'var(--color-surface)',
                            marginBottom: 'var(--space-2)',
                            cursor: 'pointer',
                          }}
                        >
                          <div style={{ fontSize: 'var(--text-xs)', fontWeight: 600, color: 'var(--color-text)', marginBottom: '3px' }}>
                            {ch?.label || `Chương ${item.chapterIndex + 1}`}
                          </div>
                          <div style={{ fontSize: 'var(--text-sm)', color: 'var(--color-text-secondary)', lineHeight: 1.4 }}>
                            {item.snippet}
                          </div>
                        </li>
                      )
                    })}
                  </ul>
                </div>
              )}
            </div>
          </aside>
        </div>
      )}
    </div>
  )
}
