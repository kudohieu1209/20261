// @vitest-environment happy-dom
import { describe, expect, it } from 'vitest'
import {
  segmentParagraph,
  selectionToRange,
  type HighlightRange,
} from './annotations'

describe('segmentParagraph', () => {
  it('trả về đoạn nguyên vẹn khi không có highlight', () => {
    const p = { start: 100, text: 'Hàn Lập nhìn quanh bốn phía.' }
    const res = segmentParagraph(p, [])
    expect(res).toEqual([{ text: 'Hàn Lập nhìn quanh bốn phía.' }])
  })

  it('cắt đúng highlight nằm trong đoạn', () => {
    const p = { start: 0, text: 'Hàn Lập nhìn quanh bốn phía.' }
    // Highlight "Hàn Lập" (0 đến 7)
    const hl: HighlightRange = { start: 0, end: 7, color: 'yellow', noteId: 'n1' }
    const res = segmentParagraph(p, [hl])

    expect(res.length).toBe(2)
    expect(res[0]).toEqual({
      text: 'Hàn Lập',
      color: 'yellow',
      noteId: 'n1',
      content: undefined,
      ttsActive: undefined,
      isSearchHit: undefined,
    })
    expect(res[1]).toEqual({
      text: ' nhìn quanh bốn phía.',
      color: undefined,
      noteId: undefined,
      content: undefined,
      ttsActive: undefined,
      isSearchHit: undefined,
    })
  })

  it('cắt chính xác highlight kéo dài qua nhiều đoạn (bị giới hạn trong đoạn)', () => {
    // Đoạn 2 bắt đầu từ vị trí 100 đến 150
    const p2 = { start: 100, text: 'Một luồng hắc phong thổi qua, mang theo hàn ý thấu xương.' }
    // Highlight bắt đầu từ đoạn 1 (offset 50) kéo dài đến giữa đoạn 2 (offset 115)
    const hl: HighlightRange = { start: 50, end: 115, color: 'amber', noteId: 'n2' }
    const res = segmentParagraph(p2, [hl])

    expect(res.length).toBe(2)
    // 100 -> 115 là 15 ký tự đầu của đoạn 2: "Một luồng hắc p"
    expect(res[0].text).toBe(p2.text.slice(0, 15))
    expect(res[0].color).toBe('amber')
    expect(res[1].text).toBe(p2.text.slice(15))
    expect(res[1].color).toBeUndefined()
  })

  it('xử lý các khoảng chồng nhau và ưu tiên TTS', () => {
    const p = { start: 0, text: 'Đại Đạo Độc Hành, vạn cổ duy nhất.' }
    // Note: 0 -> 16 ("Đại Đạo Độc Hành")
    const noteHl: HighlightRange = { start: 0, end: 16, color: 'yellow', noteId: 'n3' }
    // TTS: 8 -> 16 ("Độc Hành")
    const ttsHl: HighlightRange = { start: 8, end: 16, ttsActive: true }

    const res = segmentParagraph(p, [noteHl, ttsHl])
    expect(res.length).toBe(3)
    expect(res[0].text).toBe('Đại Đạo ')
    expect(res[0].color).toBe('yellow')
    expect(res[0].ttsActive).toBeUndefined()

    expect(res[1].text).toBe('Độc Hành')
    expect(res[1].color).toBe('yellow')
    expect(res[1].ttsActive).toBe(true)

    expect(res[2].text).toBe(', vạn cổ duy nhất.')
    expect(res[2].color).toBeUndefined()
  })
})

describe('selectionToRange', () => {
  it('tính chính xác vị trí ký tự và quote từ selection của trình duyệt', () => {
    const container = document.createElement('div')
    const p1 = document.createElement('p')
    p1.dataset.offset = '0'
    p1.textContent = 'Chương 1: Khởi đầu.'

    const p2 = document.createElement('p')
    p2.dataset.offset = '50'
    p2.textContent = 'Hàn Lập sinh ra tại một thôn làng nghèo.'

    container.appendChild(p1)
    container.appendChild(p2)
    document.body.appendChild(container)

    // Bôi đen chữ "thôn làng" trong p2
    const textNode = p2.firstChild!
    const range = document.createRange()
    const quote = 'thôn làng'
    const startIdx = p2.textContent!.indexOf(quote)
    range.setStart(textNode, startIdx)
    range.setEnd(textNode, startIdx + quote.length)

    const sel = window.getSelection()!
    sel.removeAllRanges()
    sel.addRange(range)

    const result = selectionToRange(container)
    expect(result).not.toBeNull()
    expect(result!.quote).toBe(quote)
    expect(result!.start).toBe(50 + startIdx)
    expect(result!.end).toBe(50 + startIdx + quote.length)

    document.body.removeChild(container)
  })
})
