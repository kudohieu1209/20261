import { useMemo, useRef, useState } from 'react'
import { Link, useParams } from 'react-router-dom'
import { usePageTurnControls } from '../hooks/usePageTurnControls'
import { usePaginator } from '../hooks/usePaginator'
import { useReader } from '../hooks/useReader'
import { useGlobalPageCount, type MeasureParams } from '../lib/pageCounts'

export default function ReaderPage() {
  const { bookId = '' } = useParams()
  const r = useReader(bookId)
  const [tocOpen, setTocOpen] = useState(false)
  const [toolbarOpen, setToolbarOpen] = useState(false)

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

  // Điều khiển bằng vuốt, phím và chạm 30/40/30%
  usePageTurnControls({
    containerRef,
    onNext: paginator.next,
    onPrev: paginator.prev,
    onToggleToolbar: () => setToolbarOpen((v) => !v),
  })

  // Đo đạc và đếm tổng số trang toàn sách [8551] ở nền
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

        <div style={{ textAlign: 'center', overflow: 'hidden', textOverflow: 'ellipsis', whiteSpace: 'nowrap', maxWidth: '50%' }}>
          <span style={{ fontSize: 'var(--text-sm)', fontWeight: 600 }}>{r.book.title}</span>
          <span style={{ fontSize: 'var(--text-xs)', color: 'var(--color-text-secondary)', marginLeft: '8px' }}>
            {r.chapter.label}
          </span>
        </div>

        <div style={{ display: 'flex', alignItems: 'center', gap: 'var(--space-2)' }}>
          <button
            onClick={() => setTocOpen(true)}
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

          {r.paragraphs.map((p) => (
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
              {p.text}
            </p>
          ))}
        </article>
      </main>

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

      {/* ── Modal / Sheet Mục lục phong cách Apple ── */}
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
              maxWidth: '380px',
              height: '100%',
              backgroundColor: 'var(--color-surface-raised)',
              boxShadow: 'var(--shadow-lg)',
              display: 'flex',
              flexDirection: 'column',
              overflow: 'hidden',
            }}
          >
            <div
              style={{
                padding: 'var(--space-4)',
                borderBottom: '1px solid var(--color-border)',
                display: 'flex',
                alignItems: 'center',
                justifyContent: 'space-between',
              }}
            >
              <h3 style={{ margin: 0, fontSize: 'var(--text-lg)', fontWeight: 600 }}>Mục lục</h3>
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

            <ol
              style={{
                flex: 1,
                overflowY: 'auto',
                margin: 0,
                padding: 'var(--space-2)',
                listStyle: 'none',
              }}
            >
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
          </aside>
        </div>
      )}
    </div>
  )
}
