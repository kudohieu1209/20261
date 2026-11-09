import { foldVi, foldViSameLength } from './text'

export interface SearchChapter {
  index: number
  text: string
  foldedText?: string
}

export interface SearchResultItem {
  chapterIndex: number
  offset: number
  length: number
  snippet: string
}

/**
 * Quét tuần tự tìm kiếm toàn văn trong danh sách các chương:
 * - Dùng foldViSameLength để giữ nguyên độ dài ký tự
 * - Tìm kiếm không phân biệt dấu và chữ hoa/thường
 * - Sinh snippet với ~40 ký tự ngữ cảnh trước và sau từ văn bản gốc có dấu
 */
export function searchFolded(
  chapters: SearchChapter[],
  query: string,
  limit = 50,
): SearchResultItem[] {
  const cleanQ = query.trim()
  if (!cleanQ) return []
  const foldedQuery = foldVi(cleanQ)
  if (!foldedQuery) return []

  const results: SearchResultItem[] = []
  const queryLen = foldedQuery.length

  for (const ch of chapters) {
    const folded = ch.foldedText ?? foldViSameLength(ch.text)
    let startIndex = 0

    while (startIndex < folded.length) {
      const matchIdx = folded.indexOf(foldedQuery, startIndex)
      if (matchIdx === -1) break

      const s = Math.max(0, matchIdx - 40)
      const e = Math.min(ch.text.length, matchIdx + queryLen + 40)
      const prefix = s > 0 ? '…' : ''
      const suffix = e < ch.text.length ? '…' : ''
      const snippet = prefix + ch.text.slice(s, e).replace(/\s+/g, ' ').trim() + suffix

      results.push({
        chapterIndex: ch.index,
        offset: matchIdx,
        length: queryLen,
        snippet,
      })

      if (results.length >= limit) {
        return results
      }

      startIndex = matchIdx + Math.max(1, queryLen)
    }
  }

  return results
}
