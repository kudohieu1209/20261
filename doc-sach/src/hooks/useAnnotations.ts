import { useLiveQuery } from 'dexie-react-hooks'
import { useCallback, useEffect } from 'react'
import {
  addBookmark,
  addNote,
  removeBookmark,
  removeNote,
  updateNote,
  type CreateNoteInput,
} from '../lib/annotations'
import { localDb, type LocalBookmark, type LocalNote } from '../lib/localDb'
import { pullBookAnnotations } from '../lib/sync'

export interface PageRangeLike {
  start: number
  end: number
}

export function useAnnotations(bookId: string | undefined) {
  // Khi mở sách: kéo dấu trang và ghi chú từ server về
  useEffect(() => {
    if (bookId) {
      void pullBookAnnotations(bookId)
    }
  }, [bookId])

  const bookmarks = useLiveQuery(
    async () => {
      if (!bookId) return []
      const list = await localDb.bookmarks.where('book_id').equals(bookId).toArray()
      return list.sort((a, b) => {
        if (a.chapter_index !== b.chapter_index) return a.chapter_index - b.chapter_index
        return a.char_offset - b.char_offset
      })
    },
    [bookId],
    [],
  )

  const notes = useLiveQuery(
    async () => {
      if (!bookId) return []
      const list = await localDb.notes.where('book_id').equals(bookId).toArray()
      return list.sort((a, b) => {
        if (a.chapter_index !== b.chapter_index) return a.chapter_index - b.chapter_index
        return a.char_start - b.char_start
      })
    },
    [bookId],
    [],
  )

  const notesForChapter = useCallback(
    (chapterIndex: number): LocalNote[] => {
      return (notes || []).filter((n) => n.chapter_index === chapterIndex)
    },
    [notes],
  )

  const isBookmarked = useCallback(
    (pageRange: PageRangeLike, chapterIndex: number): LocalBookmark | null => {
      if (!bookmarks) return null
      return (
        bookmarks.find(
          (b) =>
            b.chapter_index === chapterIndex &&
            b.char_offset >= pageRange.start &&
            b.char_offset <= pageRange.end,
        ) ?? null
      )
    },
    [bookmarks],
  )

  const toggleBookmark = useCallback(
    async (pageRange: PageRangeLike, chapterIndex: number, label = '') => {
      if (!bookId) return
      const existing = isBookmarked(pageRange, chapterIndex)
      if (existing) {
        await removeBookmark(existing.id)
      } else {
        await addBookmark(bookId, chapterIndex, pageRange.start, label)
      }
    },
    [bookId, isBookmarked],
  )

  const createNote = useCallback(
    async (input: Omit<CreateNoteInput, 'bookId'>) => {
      if (!bookId) return null
      return addNote({ ...input, bookId })
    },
    [bookId],
  )

  const editNote = useCallback(
    async (id: string, updates: { content?: string | null; color?: string }) => {
      return updateNote(id, updates)
    },
    [],
  )

  const deleteNote = useCallback(async (id: string) => {
    return removeNote(id)
  }, [])

  const deleteBookmark = useCallback(async (id: string) => {
    return removeBookmark(id)
  }, [])

  return {
    bookmarks: bookmarks || [],
    notes: notes || [],
    notesForChapter,
    isBookmarked,
    toggleBookmark,
    createNote,
    editNote,
    deleteNote,
    deleteBookmark,
  }
}
