import { localDb, type LocalBookmark, type LocalNote } from './localDb'
import { queueOutbox, scheduleOutboxFlush } from './sync'

export interface CreateNoteInput {
  bookId: string
  chapterIndex: number
  charStart: number
  charEnd: number
  quote: string
  color?: string
  content?: string | null
}

export interface HighlightRange {
  start: number
  end: number
  noteId?: string
  color?: string
  content?: string | null
  ttsActive?: boolean
  isSearchHit?: boolean
}

export interface TextSegment {
  text: string
  noteId?: string
  color?: string
  content?: string | null
  ttsActive?: boolean
  isSearchHit?: boolean
}

// ── 1. Thao tác Bookmarks ──────────────────────────────────────────────────
export async function addBookmark(
  bookId: string,
  chapterIndex: number,
  charOffset: number,
  label = '',
): Promise<LocalBookmark> {
  const id = crypto.randomUUID()
  const now = new Date().toISOString()
  const rec: LocalBookmark = {
    id,
    user_id: '',
    book_id: bookId,
    chapter_index: chapterIndex,
    char_offset: charOffset,
    label: label.trim() || null,
    created_at: now,
    updated_at: now,
    synced: 0,
  }

  await localDb.bookmarks.put(rec)
  const { synced: _synced, ...payload } = rec
  await queueOutbox('bookmarks', 'upsert', id, payload as unknown as Record<string, unknown>)
  scheduleOutboxFlush(2000)

  return rec
}

export async function removeBookmark(id: string): Promise<void> {
  await localDb.bookmarks.delete(id)
  await queueOutbox('bookmarks', 'delete', id)
  scheduleOutboxFlush(2000)
}

// ── 2. Thao tác Notes / Highlights ─────────────────────────────────────────
export async function addNote(input: CreateNoteInput): Promise<LocalNote> {
  const id = crypto.randomUUID()
  const now = new Date().toISOString()
  const rec: LocalNote = {
    id,
    user_id: '',
    book_id: input.bookId,
    chapter_index: input.chapterIndex,
    char_start: Math.min(input.charStart, input.charEnd),
    char_end: Math.max(input.charStart, input.charEnd),
    quote: input.quote,
    content: input.content?.trim() || null,
    color: input.color || 'yellow',
    created_at: now,
    updated_at: now,
    synced: 0,
  }

  await localDb.notes.put(rec)
  const { synced: _synced, ...payload } = rec
  await queueOutbox('notes', 'upsert', id, payload as unknown as Record<string, unknown>)
  scheduleOutboxFlush(2000)

  return rec
}

export async function updateNote(
  id: string,
  updates: { content?: string | null; color?: string },
): Promise<void> {
  const existing = await localDb.notes.get(id)
  if (!existing) return

  const now = new Date().toISOString()
  const updated: LocalNote = {
    ...existing,
    ...updates,
    updated_at: now,
    synced: 0,
  }

  await localDb.notes.put(updated)
  const { synced: _synced, ...payload } = updated
  await queueOutbox('notes', 'upsert', id, payload as unknown as Record<string, unknown>)
  scheduleOutboxFlush(2000)
}

export async function removeNote(id: string): Promise<void> {
  await localDb.notes.delete(id)
  await queueOutbox('notes', 'delete', id)
  scheduleOutboxFlush(2000)
}

// ── 3. Chuyển Selection bôi đen thành Range ký tự trong chương ─────────────
export interface TextSelectionRange {
  start: number
  end: number
  quote: string
}

export function selectionToRange(root: HTMLElement): TextSelectionRange | null {
  if (typeof window === 'undefined') return null
  const sel = window.getSelection()
  if (!sel || sel.rangeCount === 0 || sel.isCollapsed) return null

  const range = sel.getRangeAt(0)
  if (!root.contains(range.commonAncestorContainer)) return null

  const startNode = range.startContainer
  const endNode = range.endContainer

  const startPEl = (
    startNode.nodeType === Node.ELEMENT_NODE ? (startNode as Element) : startNode.parentElement
  )?.closest('[data-offset]') as HTMLElement | null

  const endPEl = (
    endNode.nodeType === Node.ELEMENT_NODE ? (endNode as Element) : endNode.parentElement
  )?.closest('[data-offset]') as HTMLElement | null

  if (!startPEl || !endPEl) return null

  const startBase = Number(startPEl.dataset.offset || 0)
  const endBase = Number(endPEl.dataset.offset || 0)

  const rStart = document.createRange()
  rStart.setStart(startPEl, 0)
  rStart.setEnd(startNode, range.startOffset)
  const charStart = startBase + rStart.toString().length

  const rEnd = document.createRange()
  rEnd.setStart(endPEl, 0)
  rEnd.setEnd(endNode, range.endOffset)
  const charEnd = endBase + rEnd.toString().length

  const finalStart = Math.min(charStart, charEnd)
  const finalEnd = Math.max(charStart, charEnd)
  const quote = range.toString()

  if (finalEnd <= finalStart || !quote.trim()) return null
  return { start: finalStart, end: finalEnd, quote }
}

// ── 4. Tách đoạn văn thành các phân đoạn (segments) highlight ──────────────
export function segmentParagraph(
  p: { start: number; text: string },
  highlights: HighlightRange[],
): TextSegment[] {
  if (!p.text) return []

  const pStart = p.start
  const pEnd = p.start + p.text.length

  // Lọc và cắt các highlight giao với đoạn văn này
  interface ActiveHl {
    start: number
    end: number
    noteId?: string
    color?: string
    content?: string | null
    ttsActive?: boolean
    isSearchHit?: boolean
  }

  const relevant: ActiveHl[] = []
  for (const h of highlights) {
    if (h.end <= pStart || h.start >= pEnd) continue
    const s = Math.max(0, h.start - pStart)
    const e = Math.min(p.text.length, h.end - pStart)
    if (e > s) {
      relevant.push({
        start: s,
        end: e,
        noteId: h.noteId,
        color: h.color,
        content: h.content,
        ttsActive: h.ttsActive,
        isSearchHit: h.isSearchHit,
      })
    }
  }

  if (relevant.length === 0) {
    return [{ text: p.text }]
  }

  // Thu thập các điểm cắt
  const cutPoints = new Set<number>([0, p.text.length])
  for (const r of relevant) {
    cutPoints.add(r.start)
    cutPoints.add(r.end)
  }

  const sortedPoints = Array.from(cutPoints).sort((a, b) => a - b)
  const segments: TextSegment[] = []

  for (let i = 0; i < sortedPoints.length - 1; i++) {
    const s = sortedPoints[i]
    const e = sortedPoints[i + 1]
    const subText = p.text.slice(s, e)
    if (!subText) continue

    // Tìm các highlight bao trùm khoảng [s, e]
    // Ưu tiên: ttsActive > isSearchHit > note
    const activeList = relevant.filter((r) => r.start <= s && r.end >= e)
    const tts = activeList.find((r) => r.ttsActive)
    const search = activeList.find((r) => r.isSearchHit)
    const note = activeList.find((r) => r.noteId || r.color)

    segments.push({
      text: subText,
      noteId: note?.noteId,
      color: note?.color,
      content: note?.content,
      ttsActive: tts?.ttsActive,
      isSearchHit: search?.isSearchHit,
    })
  }

  return segments
}
