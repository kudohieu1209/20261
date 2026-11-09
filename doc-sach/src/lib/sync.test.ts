import 'fake-indexeddb/auto'
import { beforeEach, describe, expect, it } from 'vitest'
import { localDb } from './localDb'
import { queueOutbox } from './sync'

describe('Outbox synchronization queue', () => {
  beforeEach(async () => {
    await localDb.outbox.clear()
  })

  it('gộp các thao tác lặp lại trên cùng (table, rowId), chỉ giữ thao tác mới nhất', async () => {
    // 1. Ghi nhận thao tác progress lần 1
    await queueOutbox('progress', 'upsert', 'book-1', { char_offset: 100, percent: 0.1 })
    let items = await localDb.outbox.toArray()
    expect(items.length).toBe(1)
    expect(items[0].payload).toEqual({ char_offset: 100, percent: 0.1 })

    // 2. Ghi nhận thao tác progress lần 2 cho cùng book-1
    await queueOutbox('progress', 'upsert', 'book-1', { char_offset: 250, percent: 0.25 })
    items = await localDb.outbox.toArray()
    expect(items.length).toBe(1)
    expect(items[0].payload).toEqual({ char_offset: 250, percent: 0.25 })

    // 3. Thêm thao tác cho bookmark (khác table)
    await queueOutbox('bookmarks', 'upsert', 'bm-1', { chapter_index: 2, char_offset: 50 })
    items = await localDb.outbox.toArray()
    expect(items.length).toBe(2)

    // 4. Xoá bookmark bm-1 -> gộp thay thế thao tác upsert trước đó
    await queueOutbox('bookmarks', 'delete', 'bm-1')
    items = await localDb.outbox.toArray()
    expect(items.length).toBe(2)

    const bmItem = items.find((i) => i.table === 'bookmarks' && i.rowId === 'bm-1')
    expect(bmItem?.op).toBe('delete')
  })
})
