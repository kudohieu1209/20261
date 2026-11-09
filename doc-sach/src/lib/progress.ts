import { localDb, type LocalProgress } from './localDb'
import { supabase } from './supabase'
import { flushOutbox, queueOutbox, scheduleOutboxFlush, startSync } from './sync'
import type { Book, Progress } from './types'

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
 * Lưu vị trí đọc. Ghi vào máy ngay, xếp vào outbox và đẩy lên server sau vài giây
 * (gộp nhiều lần lật trang thành một lần gửi).
 */
export async function saveProgress(
  book: Pick<Book, 'id' | 'total_chars'>,
  chapter: { index: number; charStart: number },
  charOffset: number,
): Promise<LocalProgress> {
  const percent = Math.min(1, Math.max(0, (chapter.charStart + charOffset) / Math.max(1, book.total_chars)))
  const updatedAt = new Date().toISOString()
  const rec: LocalProgress = {
    book_id: book.id,
    chapter_index: chapter.index,
    char_offset: charOffset,
    percent,
    updated_at: updatedAt,
    synced: 0,
  }
  await localDb.progress.put(rec)

  // Xếp vào outbox đồng bộ chung
  const { synced: _synced, ...payload } = rec
  await queueOutbox('progress', 'upsert', book.id, payload as unknown as Record<string, unknown>)
  scheduleOutboxFlush(3000)

  return rec
}

/** Đẩy mọi tiến độ và thay đổi trong outbox lên server. */
export async function flushProgress(): Promise<void> {
  await flushOutbox()
}

/** Gọi một lần khi app khởi động: đồng bộ khi có mạng lại hoặc khi rời tab. */
export function startProgressSync(): () => void {
  return startSync()
}
