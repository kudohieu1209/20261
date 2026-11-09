import { localDb } from '../lib/localDb'
import { foldVi, foldViSameLength } from '../lib/text'

interface CachedChapter {
  index: number
  text: string
  foldedText: string
}

let cachedBookId: string | null = null
let cachedChapters: CachedChapter[] = []
let activeSearchId = 0

self.onmessage = async (e: MessageEvent) => {
  const { type, bookId, query, limit = 50, searchId } = e.data

  if (type === 'cancel') {
    if (activeSearchId === searchId) {
      activeSearchId = 0
    }
    return
  }

  if (type !== 'search') return

  activeSearchId = searchId

  try {
    // 1. Tải toàn bộ nội dung sách và gấp chữ một lần duy nhất nếu chưa cache
    if (cachedBookId !== bookId) {
      self.postMessage({ type: 'status', searchId, message: 'Đang tải nội dung sách…' })
      const rows = await localDb.texts.where('bookId').equals(bookId).toArray()
      rows.sort((a, b) => a.index - b.index)

      cachedChapters = rows.map((r) => ({
        index: r.index,
        text: r.text,
        foldedText: foldViSameLength(r.text),
      }))
      cachedBookId = bookId
    }

    if (activeSearchId !== searchId) return

    const cleanQ = (query || '').trim()
    if (!cleanQ) {
      self.postMessage({ type: 'done', searchId, results: [], total: 0 })
      return
    }

    const foldedQuery = foldVi(cleanQ)
    const queryLen = foldedQuery.length
    const results: Array<{
      chapterIndex: number
      offset: number
      length: number
      snippet: string
    }> = []

    let batch: typeof results = []

    for (const ch of cachedChapters) {
      if (activeSearchId !== searchId) return

      let startIndex = 0
      while (startIndex < ch.foldedText.length) {
        if (activeSearchId !== searchId) return

        const matchIdx = ch.foldedText.indexOf(foldedQuery, startIndex)
        if (matchIdx === -1) break

        const s = Math.max(0, matchIdx - 40)
        const e = Math.min(ch.text.length, matchIdx + queryLen + 40)
        const prefix = s > 0 ? '…' : ''
        const suffix = e < ch.text.length ? '…' : ''
        const snippet = prefix + ch.text.slice(s, e).replace(/\s+/g, ' ').trim() + suffix

        const item = {
          chapterIndex: ch.index,
          offset: matchIdx,
          length: queryLen,
          snippet,
        }

        results.push(item)
        batch.push(item)

        // Gửi theo từng đợt để kết quả hiện dần mượt mà
        if (batch.length >= 10) {
          self.postMessage({ type: 'batch', searchId, items: batch })
          batch = []
        }

        if (results.length >= limit) {
          break
        }

        startIndex = matchIdx + Math.max(1, queryLen)
      }

      if (results.length >= limit) break
    }

    if (batch.length > 0) {
      self.postMessage({ type: 'batch', searchId, items: batch })
    }

    self.postMessage({ type: 'done', searchId, results, total: results.length })
  } catch (err) {
    self.postMessage({ type: 'error', searchId, error: (err as Error).message })
  }
}
