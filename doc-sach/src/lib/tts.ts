export interface Sentence {
  start: number
  end: number
  text: string
}

const MAX_SENTENCE_LEN = 200

/**
 * Tách các đoạn văn thành danh sách các câu hoàn chỉnh:
 * - Cắt theo dấu chấm, chấm than, hỏi, ba chấm, dấu ngoặc kép: . ! ? … " ”
 * - Giới hạn tối đa ~200 ký tự mỗi câu (cắt thêm theo dấu phẩy hoặc khoảng trắng)
 *   để tránh lỗi Chrome Android tự ngắt giọng khi câu quá dài.
 * - Giữ nguyên vị trí ký tự tuyệt đối [start, end] trong chương.
 */
export function splitSentences(paragraphs: { start: number; text: string }[]): Sentence[] {
  const sentences: Sentence[] = []
  const re = /[^.!?…]+[.!?…]+["”'»]*|[^.!?…]+$/gu

  for (const p of paragraphs) {
    if (!p.text || !p.text.trim()) continue

    re.lastIndex = 0
    let match: RegExpExecArray | null

    while ((match = re.exec(p.text)) !== null) {
      const raw = match[0]
      const lead = raw.length - raw.trimStart().length
      const trail = raw.length - raw.trimEnd().length
      const trimmed = raw.trim()
      if (!trimmed) continue

      const baseStart = p.start + match.index + lead
      const baseEnd = p.start + match.index + raw.length - trail

      if (trimmed.length <= MAX_SENTENCE_LEN) {
        sentences.push({
          start: baseStart,
          end: baseEnd,
          text: trimmed,
        })
      } else {
        // Cắt câu dài > 200 ký tự
        let subOffset = 0
        while (subOffset < trimmed.length) {
          const remaining = trimmed.length - subOffset
          if (remaining <= MAX_SENTENCE_LEN) {
            const sub = trimmed.slice(subOffset)
            sentences.push({
              start: baseStart + subOffset,
              end: baseEnd,
              text: sub,
            })
            break
          }

          const chunk = trimmed.slice(subOffset, subOffset + MAX_SENTENCE_LEN)
          let breakIdx = -1

          // Ưu tiên ngắt tại dấu phẩy, chấm phẩy, gạch ngang
          const punctMatch = /[,;:—–]\s*/g
          let pm: RegExpExecArray | null
          while ((pm = punctMatch.exec(chunk)) !== null) {
            breakIdx = pm.index + pm[0].length
          }

          if (breakIdx === -1) {
            // Ngắt tại khoảng trắng gần nhất
            breakIdx = chunk.lastIndexOf(' ')
          }

          if (breakIdx <= 0) {
            breakIdx = MAX_SENTENCE_LEN
          }

          const sub = trimmed.slice(subOffset, subOffset + breakIdx)
          sentences.push({
            start: baseStart + subOffset,
            end: baseStart + subOffset + breakIdx,
            text: sub,
          })

          subOffset += breakIdx
        }
      }
    }
  }

  return sentences
}

const TTS_STORAGE_KEY = 'doc-sach-tts-settings'

export interface TtsSettings {
  voiceURI: string | null
  rate: number
}

export function getStoredTtsSettings(): TtsSettings {
  try {
    const raw = localStorage.getItem(TTS_STORAGE_KEY)
    if (raw) {
      const parsed = JSON.parse(raw)
      return {
        voiceURI: parsed.voiceURI ?? null,
        rate: typeof parsed.rate === 'number' ? Math.max(0.8, Math.min(2, parsed.rate)) : 1.0,
      }
    }
  } catch {
    // Bỏ qua lỗi localStorage
  }
  return { voiceURI: null, rate: 1.0 }
}

export function saveStoredTtsSettings(settings: Partial<TtsSettings>): void {
  try {
    const current = getStoredTtsSettings()
    const updated = { ...current, ...settings }
    localStorage.setItem(TTS_STORAGE_KEY, JSON.stringify(updated))
  } catch {
    // Bỏ qua lỗi localStorage
  }
}
