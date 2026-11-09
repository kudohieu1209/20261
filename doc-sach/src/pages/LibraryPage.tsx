// PLACEHOLDER UI — agy thiết kế lại phần trình bày, giữ nguyên dữ liệu từ useLibrary().
import { useRef } from 'react'
import { Link } from 'react-router-dom'
import { useLibrary } from '../hooks/useLibrary'
import { signOut } from '../lib/auth'
import type { ImportStage } from '../lib/books'
import type { BookStatus } from '../lib/types'

const STAGE_LABEL: Record<ImportStage, string> = {
  reading: 'Đang đọc file',
  parsing: 'Đang tách chương',
  uploading: 'Đang tải lên',
  saving: 'Đang lưu',
}

const STATUS_LABEL: Record<BookStatus, string> = {
  to_read: 'Muốn đọc',
  reading: 'Đang đọc',
  finished: 'Đã đọc xong',
}

export default function LibraryPage() {
  const { items, loading, importing, error, importFile, changeStatus, remove } = useLibrary()
  const fileInput = useRef<HTMLInputElement>(null)

  return (
    <main>
      <header>
        <h1>Thư viện</h1>
        <button onClick={() => fileInput.current?.click()} disabled={importing !== null}>
          {importing
            ? `${STAGE_LABEL[importing.stage]}${importing.total ? ` ${importing.done}/${importing.total}` : ''}…`
            : 'Thêm sách (.epub, .txt)'}
        </button>
        <input
          ref={fileInput}
          type="file"
          accept=".epub,.txt,application/epub+zip,text/plain"
          hidden
          onChange={(e) => {
            const f = e.target.files?.[0]
            if (f) void importFile(f)
            e.target.value = ''
          }}
        />
        <button onClick={() => void signOut()}>Đăng xuất</button>
      </header>

      {error && <p role="alert">{error}</p>}
      {loading && <p>Đang tải…</p>}
      {!loading && items.length === 0 && <p>Chưa có sách nào.</p>}

      <ul>
        {items.map(({ book, progress }) => (
          <li key={book.id}>
            <Link to={`/read/${book.id}`}>
              <strong>{book.title}</strong>
              {book.author && <span> — {book.author}</span>}
            </Link>
            <div>
              {book.chapter_count} chương · {Math.round((progress?.percent ?? 0) * 100)}% · {STATUS_LABEL[book.status]}
              {book.finished_at && ` · xong ngày ${new Date(book.finished_at).toLocaleDateString('vi-VN')}`}
            </div>
            <select value={book.status} onChange={(e) => void changeStatus(book, e.target.value as BookStatus)}>
              {Object.entries(STATUS_LABEL).map(([v, label]) => (
                <option key={v} value={v}>{label}</option>
              ))}
            </select>
            <button onClick={() => confirm(`Xóa "${book.title}"?`) && void remove(book)}>Xóa</button>
          </li>
        ))}
      </ul>
    </main>
  )
}
