// PLACEHOLDER UI — chế độ cuộn dọc đơn giản để kiểm tra dữ liệu.
// agy thiết kế lại phần trình bày; chế độ lật trang 2 trang (chia trang) sẽ thêm sau
// dưới dạng hook usePaginator. Giữ nguyên các lời gọi useReader().
import { useEffect, useRef, useState } from 'react'
import { Link, useParams } from 'react-router-dom'
import { useReader } from '../hooks/useReader'

export default function ReaderPage() {
  const { bookId = '' } = useParams()
  const r = useReader(bookId)
  const [tocOpen, setTocOpen] = useState(false)
  const contentRef = useRef<HTMLElement>(null)

  // Khôi phục vị trí: cuộn tới đoạn chứa restoreOffset.
  useEffect(() => {
    const root = contentRef.current
    if (!root || r.paragraphs.length === 0) return
    if (r.restoreOffset === null) {
      window.scrollTo(0, 0)
      return
    }
    const target = [...root.querySelectorAll<HTMLElement>('[data-offset]')]
      .filter((el) => Number(el.dataset.offset) <= r.restoreOffset!)
      .pop()
    target?.scrollIntoView({ block: 'start' })
  }, [r.paragraphs, r.restoreOffset])

  // Báo vị trí: đoạn đầu tiên đang hiện trên màn hình.
  useEffect(() => {
    const root = contentRef.current
    if (!root) return
    let timer: ReturnType<typeof setTimeout>
    const onScroll = () => {
      clearTimeout(timer)
      timer = setTimeout(() => {
        const first = [...root.querySelectorAll<HTMLElement>('[data-offset]')].find(
          (el) => el.getBoundingClientRect().bottom > 0,
        )
        if (first) void r.reportPosition(Number(first.dataset.offset))
        const atEnd = window.innerHeight + window.scrollY >= document.body.scrollHeight - 4
        if (atEnd && r.isLastChapter) void r.markFinished()
      }, 500)
    }
    window.addEventListener('scroll', onScroll, { passive: true })
    return () => {
      clearTimeout(timer)
      window.removeEventListener('scroll', onScroll)
    }
  }, [r])

  if (r.error) return <p role="alert">{r.error}</p>
  if (r.loading || !r.book || !r.toc || !r.chapter) return <p>Đang mở sách…</p>

  const volume = r.chapter.volumeIndex !== null ? r.toc.volumes[r.chapter.volumeIndex] : null

  return (
    <div>
      <nav>
        <Link to="/">← Thư viện</Link>
        <span> {r.book.title} · {(r.percent * 100).toFixed(1)}% </span>
        <button onClick={() => setTocOpen((v) => !v)}>Mục lục</button>
      </nav>

      {tocOpen && (
        <aside>
          <ol>
            {r.toc.chapters.map((c) => (
              <li key={c.index}>
                <button
                  onClick={() => {
                    r.goToChapter(c.index)
                    setTocOpen(false)
                  }}
                  aria-current={c.index === r.chapter!.index}
                >
                  {c.label}{c.title && `: ${c.title}`}
                </button>
              </li>
            ))}
          </ol>
        </aside>
      )}

      <article ref={contentRef} style={{ fontFamily: 'var(--font-book)', maxWidth: '40em', margin: '0 auto' }}>
        {volume && <p>{volume.label}{volume.title && `: ${volume.title}`}</p>}
        <h2>{r.chapter.label}</h2>
        {r.chapter.title && <h1>{r.chapter.title}</h1>}
        {r.chapter.originalTitle && <p lang="zh">{r.chapter.originalTitle}</p>}
        {r.paragraphs.map((p) => (
          <p key={p.start} data-offset={p.start}>{p.text}</p>
        ))}
      </article>

      <footer>
        <button onClick={r.prevChapter} disabled={r.chapter.index === 0}>‹ Chương trước</button>
        <button onClick={r.nextChapter} disabled={r.isLastChapter}>Chương sau ›</button>
      </footer>
    </div>
  )
}
