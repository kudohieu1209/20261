import { useCallback, useEffect, useRef, useState } from 'react'
import type { SearchResultItem } from '../lib/search'

export function useBookSearch(bookId: string | undefined) {
  const [query, setQueryState] = useState('')
  const [results, setResults] = useState<SearchResultItem[]>([])
  const [searching, setSearching] = useState(false)
  const [total, setTotal] = useState(0)

  const workerRef = useRef<Worker | null>(null)
  const searchIdRef = useRef(0)
  const timerRef = useRef<ReturnType<typeof setTimeout> | undefined>(undefined)

  // Khởi tạo worker
  useEffect(() => {
    if (typeof window === 'undefined') return

    const worker = new Worker(new URL('../workers/search.worker.ts', import.meta.url), {
      type: 'module',
    })

    worker.onmessage = (e: MessageEvent) => {
      const { type, searchId, items, results: finalResults, total: finalTotal } = e.data

      // Bỏ qua kết quả của các lượt tìm kiếm cũ đã bị huỷ
      if (searchId !== searchIdRef.current) return

      if (type === 'batch') {
        setResults((prev) => [...prev, ...items])
      } else if (type === 'done') {
        if (finalResults) {
          setResults(finalResults)
        }
        setTotal(finalTotal)
        setSearching(false)
      } else if (type === 'error') {
        setSearching(false)
      }
    }

    workerRef.current = worker

    return () => {
      worker.terminate()
      workerRef.current = null
    }
  }, [bookId])

  const cancelSearch = useCallback(() => {
    clearTimeout(timerRef.current)
    if (workerRef.current && searchIdRef.current > 0) {
      workerRef.current.postMessage({ type: 'cancel', searchId: searchIdRef.current })
    }
    setSearching(false)
  }, [])

  const executeSearch = useCallback(
    (q: string) => {
      const trimmed = q.trim()
      if (!trimmed || !bookId || !workerRef.current) {
        setResults([])
        setTotal(0)
        setSearching(false)
        return
      }

      cancelSearch()

      const nextId = searchIdRef.current + 1
      searchIdRef.current = nextId

      setResults([])
      setTotal(0)
      setSearching(true)

      workerRef.current.postMessage({
        type: 'search',
        bookId,
        query: trimmed,
        limit: 60,
        searchId: nextId,
      })
    },
    [bookId, cancelSearch],
  )

  const setQuery = useCallback(
    (newQuery: string) => {
      setQueryState(newQuery)
      clearTimeout(timerRef.current)

      if (!newQuery.trim()) {
        cancelSearch()
        setResults([])
        setTotal(0)
        return
      }

      setSearching(true)
      timerRef.current = setTimeout(() => {
        executeSearch(newQuery)
      }, 300)
    },
    [executeSearch, cancelSearch],
  )

  return {
    query,
    setQuery,
    results,
    searching,
    total,
    cancelSearch,
  }
}
