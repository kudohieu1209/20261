import Dexie, { type Table } from 'dexie'
import type { Book, Chapter, Progress, Volume } from './types'

/** Thông tin chương (không kèm nội dung) — đủ để vẽ mục lục. */
export type ChapterMeta = Omit<Chapter, 'text'> & { bookId: string; charLength: number }
export type LocalVolume = Volume & { bookId: string }
export interface ChapterText {
  bookId: string
  index: number
  text: string
}
export interface CoverCache {
  bookId: string
  blob: Blob
}
/** synced: 0 = chưa đẩy lên server, 1 = đã đồng bộ (Dexie không index được boolean). */
export type LocalProgress = Progress & { synced: 0 | 1 }

/** Cache trên máy (IndexedDB). Nguồn sự thật vẫn là Supabase. */
class LocalDb extends Dexie {
  books!: Table<Book, string>
  volumes!: Table<LocalVolume, [string, number]>
  chapters!: Table<ChapterMeta, [string, number]>
  texts!: Table<ChapterText, [string, number]>
  progress!: Table<LocalProgress, string>
  covers!: Table<CoverCache, string>

  constructor() {
    super('doc-sach')
    this.version(1).stores({
      books: 'id, updated_at',
      volumes: '[bookId+index], bookId',
      chapters: '[bookId+index], bookId',
      texts: '[bookId+index], bookId',
      progress: 'book_id, synced',
      covers: 'bookId',
    })
  }
}

export const localDb = new LocalDb()
