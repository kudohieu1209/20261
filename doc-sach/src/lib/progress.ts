import { localDb, type LocalProgress } from './localDb'
import { supabase } from './supabase'
import type { Book, Progress } from './types'

const SYNC_DELAY_MS = 3000
let timer: ReturnType<typeof setTimeout> | undefined

/** Lấy tiến độ mới nhất giữa bản trên máy và bản trên server. */
export async function getProgress(bookId: string): Promise<Progress | null> {
  const local = (await localDb.progress.get(bookId)) ?? null
  try {
    const { data } = await supabase
      .from('progress')
      .select('book_id, chapter_index, char_offset, percent, updated_at')
      .eq('book_id', bookId)
      .maybeSingle<Progress>()
    if (data && (!local || data.updated_at > local.updated_at)) {
      await localDb.progress.put({ ...data, synced: 1 })
      return data
    }
  } catch {
    // mất mạng: dùng bản trên máy
  }
  return local
}

/**
 * Lưu vị trí đọc. Ghi vào máy ngay, đẩy lên server sau vài giây
 * (gộp nhiều lần lật trang thành một lần gửi).
 */
export async function saveProgress(
  book: Pick<Book, 'id' | 'total_chars'>,
  chapter: { index: number; charStart: number },
  charOffset: number,
): Promise<LocalProgress> {
  const percent = Math.min(1, Math.max(0, (chapter.charStart + charOffset) / Math.max(1, book.total_chars)))
  const rec: LocalProgress = {
    book_id: book.id,
    chapter_index: chapter.index,
    char_offset: charOffset,
    percent,
    updated_at: new Date().toISOString(),
    synced: 0,
  }
  await localDb.progress.put(rec)
  clearTimeout(timer)
  timer = setTimeout(() => void flushProgress(), SYNC_DELAY_MS)
  return rec
}

/** Đẩy mọi tiến độ chưa đồng bộ lên server. */
export async function flushProgress(): Promise<void> {
  clearTimeout(timer)
  const pending = await localDb.progress.where('synced').equals(0).toArray()
  if (pending.length === 0) return
  const rows = pending.map(({ synced: _synced, ...p }) => p)
  const { error } = await supabase.from('progress').upsert(rows, { onConflict: 'book_id' })
  if (error) return // thử lại lần sau (khi có mạng / khi lưu tiếp)
  await localDb.transaction('rw', localDb.progress, async () => {
    for (const p of pending) {
      const cur = await localDb.progress.get(p.book_id)
      // chỉ đánh dấu đã đồng bộ nếu không có bản mới hơn được ghi trong lúc gửi
      if (cur && cur.updated_at === p.updated_at) await localDb.progress.update(p.book_id, { synced: 1 })
    }
  })
}

/** Gọi một lần khi app khởi động: đồng bộ khi có mạng lại hoặc khi rời tab. */
export function startProgressSync(): () => void {
  const onOnline = () => void flushProgress()
  const onHide = () => {
    if (document.visibilityState === 'hidden') void flushProgress()
  }
  window.addEventListener('online', onOnline)
  document.addEventListener('visibilitychange', onHide)
  void flushProgress()
  return () => {
    window.removeEventListener('online', onOnline)
    document.removeEventListener('visibilitychange', onHide)
  }
}
