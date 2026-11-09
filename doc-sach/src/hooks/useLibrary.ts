import { useCallback, useEffect, useState } from 'react'
import { deleteBook, importBook, listLibrary, setStatus, type ImportStage, type LibraryItem } from '../lib/books'
import type { Book, BookStatus } from '../lib/types'

/** Dữ liệu cho màn hình Thư viện. UI chỉ cần gọi các hàm trả về. */
export function useLibrary() {
  const [items, setItems] = useState<LibraryItem[]>([])
  const [loading, setLoading] = useState(true)
  /** null = không nhập; còn lại: bước hiện tại + tiến độ (done/total khi đang tách chương EPUB) */
  const [importing, setImporting] = useState<{ stage: ImportStage; done?: number; total?: number } | null>(null)
  const [error, setError] = useState<string | null>(null)

  const refresh = useCallback(async () => {
    try {
      setItems(await listLibrary())
      setError(null)
    } catch (e) {
      setError((e as Error).message)
    } finally {
      setLoading(false)
    }
  }, [])

  useEffect(() => {
    void refresh()
  }, [refresh])

  const importFile = useCallback(
    async (file: File, meta?: { title?: string; author?: string }) => {
      setImporting({ stage: 'reading' })
      try {
        const book = await importBook(file, meta, (stage, done, total) => setImporting({ stage, done, total }))
        await refresh()
        return book
      } catch (e) {
        setError((e as Error).message)
        return null
      } finally {
        setImporting(null)
      }
    },
    [refresh],
  )

  const changeStatus = useCallback(
    async (book: Book, status: BookStatus) => {
      await setStatus(book, status)
      await refresh()
    },
    [refresh],
  )

  const remove = useCallback(
    async (book: Book) => {
      await deleteBook(book)
      await refresh()
    },
    [refresh],
  )

  return { items, loading, importing, error, refresh, importFile, changeStatus, remove }
}
