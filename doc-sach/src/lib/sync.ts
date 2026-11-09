import { localDb, type LocalBookmark, type LocalNote, type OutboxItem } from './localDb'
import { supabase } from './supabase'
import type { Bookmark, Note } from './types'

let flushTimer: ReturnType<typeof setTimeout> | undefined
let isFlushing = false

/**
 * Thêm hoặc cập nhật thao tác vào outbox.
 * Nếu đã có thao tác cho cùng (table, rowId), thao tác cũ sẽ bị xoá để gộp chỉ giữ thao tác mới nhất.
 */
export async function queueOutbox(
  table: OutboxItem['table'],
  op: OutboxItem['op'],
  rowId: string,
  payload?: Record<string, unknown>,
): Promise<void> {
  await localDb.transaction('rw', localDb.outbox, async () => {
    await localDb.outbox.where('[table+rowId]').equals([table, rowId]).delete()
    await localDb.outbox.add({ table, op, rowId, payload })
  })
}

/** Lên lịch đẩy outbox sau một khoảng thời gian (mặc định 3s). */
export function scheduleOutboxFlush(delayMs = 3000): void {
  clearTimeout(flushTimer)
  flushTimer = setTimeout(() => void flushOutbox(), delayMs)
}

/**
 * Đẩy toàn bộ hàng đợi outbox lên Supabase.
 * Nếu mất mạng hoặc gặp lỗi, dừng lại để thử lại lần sau.
 */
export async function flushOutbox(): Promise<void> {
  clearTimeout(flushTimer)
  if (isFlushing) return
  isFlushing = true

  try {
    const items = await localDb.outbox.orderBy('id').toArray()
    for (const item of items) {
      if (!item.id) continue

      let err: unknown = null

      if (item.table === 'progress') {
        if (item.op === 'upsert' && item.payload) {
          const { error } = await supabase.from('progress').upsert(item.payload, { onConflict: 'book_id' })
          err = error
          if (!error) {
            await localDb.progress.update(item.rowId, { synced: 1 })
          }
        }
      } else if (item.table === 'bookmarks') {
        if (item.op === 'upsert' && item.payload) {
          const { error } = await supabase.from('bookmarks').upsert(item.payload, { onConflict: 'id' })
          err = error
          if (!error) {
            await localDb.bookmarks.update(item.rowId, { synced: 1 })
          }
        } else if (item.op === 'delete') {
          const { error } = await supabase.from('bookmarks').delete().eq('id', item.rowId)
          err = error
        }
      } else if (item.table === 'notes') {
        if (item.op === 'upsert' && item.payload) {
          const { error } = await supabase.from('notes').upsert(item.payload, { onConflict: 'id' })
          err = error
          if (!error) {
            await localDb.notes.update(item.rowId, { synced: 1 })
          }
        } else if (item.op === 'delete') {
          const { error } = await supabase.from('notes').delete().eq('id', item.rowId)
          err = error
        }
      }

      if (err) {
        // Gặp lỗi mạng hoặc auth: dừng lại, để outbox lần sau thử tiếp
        break
      }

      // Đẩy thành công: xoá khỏi outbox
      await localDb.outbox.delete(item.id)
    }
  } catch {
    // Mất mạng
  } finally {
    isFlushing = false
  }
}

/**
 * Kích hoạt đồng bộ tự động:
 * - Khi có mạng trở lại (online)
 * - Khi ẩn tab hoặc rời app (visibilitychange)
 * - Chạy ngay khi khởi động
 */
export function startSync(): () => void {
  const onOnline = () => void flushOutbox()
  const onHide = () => {
    if (document.visibilityState === 'hidden') void flushOutbox()
  }

  window.addEventListener('online', onOnline)
  document.addEventListener('visibilitychange', onHide)
  void flushOutbox()

  return () => {
    window.removeEventListener('online', onOnline)
    document.removeEventListener('visibilitychange', onHide)
  }
}

/**
 * Tải dấu trang và ghi chú từ server rồi ghép vào máy.
 * Bản ghi đã đồng bộ (synced = 1) mà server không còn thì xoá ở máy.
 * Nhờ vậy xoá trên máy này thì máy kia cũng mất, không cần cột tombstone.
 */
export async function pullBookAnnotations(bookId: string): Promise<void> {
  try {
    const [bmRes, noteRes] = await Promise.all([
      supabase.from('bookmarks').select('*').eq('book_id', bookId),
      supabase.from('notes').select('*').eq('book_id', bookId),
    ])

    if (bmRes.error || noteRes.error) return

    const serverBookmarks = (bmRes.data ?? []) as Bookmark[]
    const serverNotes = (noteRes.data ?? []) as Note[]

    await localDb.transaction('rw', [localDb.bookmarks, localDb.notes], async () => {
      // 1. Đồng bộ Bookmarks
      const localBms = await localDb.bookmarks.where('book_id').equals(bookId).toArray()
      const serverBmMap = new Map(serverBookmarks.map((b) => [b.id, b]))

      for (const lb of localBms) {
        if (lb.synced === 1) {
          if (!serverBmMap.has(lb.id)) {
            // Server đã xoá -> xoá ở máy
            await localDb.bookmarks.delete(lb.id)
          } else {
            // Cập nhật bản mới từ server
            const sb = serverBmMap.get(lb.id)!
            await localDb.bookmarks.put({ ...sb, synced: 1 } as LocalBookmark)
          }
        }
      }

      for (const sb of serverBookmarks) {
        const local = await localDb.bookmarks.get(sb.id)
        if (!local) {
          await localDb.bookmarks.put({ ...sb, synced: 1 } as LocalBookmark)
        }
      }

      // 2. Đồng bộ Notes
      const localNotes = await localDb.notes.where('book_id').equals(bookId).toArray()
      const serverNoteMap = new Map(serverNotes.map((n) => [n.id, n]))

      for (const ln of localNotes) {
        if (ln.synced === 1) {
          if (!serverNoteMap.has(ln.id)) {
            // Server đã xoá -> xoá ở máy
            await localDb.notes.delete(ln.id)
          } else {
            const sn = serverNoteMap.get(ln.id)!
            await localDb.notes.put({ ...sn, synced: 1 } as LocalNote)
          }
        }
      }

      for (const sn of serverNotes) {
        const local = await localDb.notes.get(sn.id)
        if (!local) {
          await localDb.notes.put({ ...sn, synced: 1 } as LocalNote)
        }
      }
    })
  } catch {
    // Mất mạng: giữ nguyên dữ liệu local
  }
}
