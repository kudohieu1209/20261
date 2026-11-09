import { describe, expect, it } from 'vitest'
import { splitSentences } from './tts'

describe('splitSentences', () => {
  it('ngắt câu đúng các dấu chấm, chấm than, hỏi, ba chấm và dấu ngoặc kép', () => {
    const paragraphs = [
      {
        start: 0,
        text: 'Hàn Lập nhìn quanh bốn phía. "Ai ở đó?" hắn cất tiếng hỏi… "Không một bóng người!"',
      },
    ]

    const sentences = splitSentences(paragraphs)
    expect(sentences.length).toBe(4)

    expect(sentences[0].text).toBe('Hàn Lập nhìn quanh bốn phía.')
    expect(sentences[0].start).toBe(0)
    expect(sentences[0].end).toBe(28)

    expect(sentences[1].text).toBe('"Ai ở đó?"')
    expect(sentences[2].text).toBe('hắn cất tiếng hỏi…')
    expect(sentences[3].text).toBe('"Không một bóng người!"')
  })

  it('câu quá 200 ký tự được ngắt khéo léo theo dấu phẩy hoặc khoảng trắng', () => {
    const longText =
      'Đại Đạo Độc Hành muôn vàn gian nan, ' +
      'người tu tiên phải kiên định tâm trí trước mọi cám dỗ của hồng trần mênh mông, ' +
      'bởi vì chỉ cần một bước lỡ chân là vạn kiếp bất phục, ' +
      'thân tử đạo tiêu không còn cơ hội quay đầu lại nữa.'

    expect(longText.length).toBeGreaterThan(200)

    const paragraphs = [{ start: 50, text: longText }]
    const sentences = splitSentences(paragraphs)

    expect(sentences.length).toBeGreaterThan(1)
    for (const s of sentences) {
      expect(s.text.length).toBeLessThanOrEqual(200)
      // Đảm bảo trích đúng slice từ chuỗi gốc
      expect(longText.slice(s.start - 50, s.end - 50)).toBe(s.text)
    }
  })

  it('bỏ qua đoạn văn rỗng', () => {
    const paragraphs = [
      { start: 0, text: '' },
      { start: 10, text: '   ' },
      { start: 20, text: 'Một câu duy nhất.' },
    ]
    const sentences = splitSentences(paragraphs)
    expect(sentences.length).toBe(1)
    expect(sentences[0].text).toBe('Một câu duy nhất.')
  })
})
