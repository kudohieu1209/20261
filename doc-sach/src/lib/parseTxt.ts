import type { Chapter, ParsedBook, Volume } from './types'

/**
 * Tăng số này mỗi khi đổi cách tách chương: chỉ số chương thay đổi
 * thì ghi chú/tiến độ (neo theo chapter_index) có thể lệch.
 */
export const PARSER_VERSION = 2

const MAX_HEADING_LEN = 120

// Nhóm: 1 = từ khóa, 2 = số, 3 = dấu ngăn cách (nếu có), 4 = tên
const VOLUME_RE =
  /^(quyển|quyen|tập|tap|volume|vol\.?)\s*(\d+|[ivxlc]+)(?:\s*([:：.\-–—])\s*|\s+|$)(.*)$/i
const CHAPTER_RE =
  /^(chương|chuong|chapter|chap\.?|hồi|hoi)\s*(\d+)(?:\s*([:：.\-–—])\s*|\s+|$)(.*)$/i
/** Từ khóa dễ trùng với câu văn thường ("Hồi 3 giờ sáng...", "tập 2 người...") */
const WEAK_KEYWORDS = new Set(['hồi', 'hoi', 'tập', 'tap'])
/** Dòng chỉ gồm chữ Hán + dấu câu/khoảng trắng/số, ví dụ "第七卷 纵横人界". */
const HAN_LINE_RE = /^[\p{Script=Han}\p{P}\s\d]+$/u
const HAS_HAN_RE = /\p{Script=Han}/u

/** Giải mã file TXT: thử UTF-8 (có/không BOM), UTF-16, rồi Windows-1258. */
export function decodeText(bytes: Uint8Array): string {
  if (bytes[0] === 0xff && bytes[1] === 0xfe) return new TextDecoder('utf-16le').decode(bytes)
  if (bytes[0] === 0xfe && bytes[1] === 0xff) return new TextDecoder('utf-16be').decode(bytes)
  try {
    return new TextDecoder('utf-8', { fatal: true }).decode(bytes)
  } catch {
    return new TextDecoder('windows-1258').decode(bytes)
  }
}

function capitalize(word: string): string {
  const w = word.toLowerCase().replace(/\.$/, '')
  const map: Record<string, string> = {
    quyen: 'Quyển', quyển: 'Quyển', tap: 'Tập', tập: 'Tập', volume: 'Quyển', vol: 'Quyển',
    chuong: 'Chương', chương: 'Chương', chapter: 'Chương', chap: 'Chương', hoi: 'Hồi', hồi: 'Hồi',
  }
  return map[w] ?? w.charAt(0).toUpperCase() + w.slice(1)
}

/**
 * Chặn nhận nhầm câu văn là tiêu đề. Tiêu đề hợp lệ khi:
 * có dấu ngăn cách / chỉ có số, hoặc từ khóa viết hoa và không thuộc nhóm dễ trùng.
 */
function isHeading(m: RegExpExecArray): boolean {
  const keyword = m[1]
  const hasSep = m[3] !== undefined || m[4].trim() === ''
  if (hasSep) return true
  if (WEAK_KEYWORDS.has(keyword.toLowerCase())) return false
  return keyword[0] === keyword[0].toUpperCase()
}

function romanToInt(s: string): number {
  const v: Record<string, number> = { i: 1, v: 5, x: 10, l: 50, c: 100 }
  let total = 0
  const lower = s.toLowerCase()
  for (let i = 0; i < lower.length; i++) {
    const cur = v[lower[i]]
    const next = v[lower[i + 1]] ?? 0
    total += cur < next ? -cur : cur
  }
  return total
}

function parseNumber(s: string): number {
  return /^\d+$/.test(s) ? Number(s) : romanToInt(s)
}

export interface HeadingMatch {
  /** "Quyển 7" / "Chương 1125" */
  label: string
  /** phần tên sau số, có thể rỗng */
  title: string
}

/** Nhận dạng dòng tiêu đề Quyển. Dùng chung cho TXT và EPUB. */
export function matchVolume(line: string): HeadingMatch | null {
  const s = line.trim()
  if (s.length > MAX_HEADING_LEN) return null
  const m = VOLUME_RE.exec(s)
  return m && isHeading(m) ? { label: `${capitalize(m[1])} ${parseNumber(m[2])}`, title: m[4].trim() } : null
}

/** Nhận dạng dòng tiêu đề Chương. Dùng chung cho TXT và EPUB. */
export function matchChapter(line: string): HeadingMatch | null {
  const s = line.trim()
  if (s.length > MAX_HEADING_LEN) return null
  const m = CHAPTER_RE.exec(s)
  return m && isHeading(m) ? { label: `${capitalize(m[1])} ${Number(m[2])}`, title: m[4].trim() } : null
}

/** Dòng tên gốc chữ Hán, ví dụ "第七卷 纵横人界". */
export function isHanLine(line: string): boolean {
  return line.length <= MAX_HEADING_LEN && HAN_LINE_RE.test(line) && HAS_HAN_RE.test(line)
}

/**
 * Tách file TXT thành Quyển/Chương.
 * - Dòng tiêu đề: "Quyển 7: Tên", "Chương 1125 - Tên", "chuong 3. Tên", "Chapter 4"...
 * - Dòng chữ Hán ngay sau tiêu đề được coi là tên gốc.
 * - Nội dung trước chương đầu tiên thành mục "Giới thiệu".
 */
export function parseTxt(raw: string): ParsedBook {
  const lines = raw.replace(/^﻿/, '').replace(/\r\n?/g, '\n').split('\n')

  const volumes: Volume[] = []
  const chapters: Chapter[] = []
  let current: Omit<Chapter, 'text' | 'charStart'> & { paragraphs: string[] } = {
    index: 0,
    volumeIndex: null,
    label: 'Giới thiệu',
    title: '',
    originalTitle: null,
    paragraphs: [],
  }
  /** Tiêu đề vừa gặp (quyển hoặc chương) đang chờ dòng tên gốc chữ Hán. */
  let awaitingOriginal: { originalTitle: string | null } | null = null

  const pushCurrent = () => {
    const isEmptyIntro = current.label === 'Giới thiệu' && current.paragraphs.length === 0
    if (isEmptyIntro) return
    const { paragraphs, ...meta } = current
    chapters.push({ ...meta, index: chapters.length, text: paragraphs.join('\n'), charStart: 0 })
  }

  for (const rawLine of lines) {
    const line = rawLine.trim().normalize('NFC')
    if (!line) continue

    if (awaitingOriginal && isHanLine(line)) {
      awaitingOriginal.originalTitle = line
      awaitingOriginal = null
      continue
    }
    awaitingOriginal = null

    const vm = matchVolume(line)
    if (vm) {
      const vol: Volume = { index: volumes.length, ...vm, originalTitle: null }
      volumes.push(vol)
      // Chương đang mở (nếu có) vẫn thuộc quyển trước; chương sau mới thuộc quyển này.
      awaitingOriginal = vol
      continue
    }
    const cm = matchChapter(line)
    if (cm) {
      pushCurrent()
      current = {
        index: 0,
        volumeIndex: volumes.length ? volumes.length - 1 : null,
        ...cm,
        originalTitle: null,
        paragraphs: [],
      }
      awaitingOriginal = current
      continue
    }

    current.paragraphs.push(line)
  }
  pushCurrent()

  let offset = 0
  for (const ch of chapters) {
    ch.charStart = offset
    offset += ch.text.length
  }

  return { volumes, chapters, totalChars: offset }
}
