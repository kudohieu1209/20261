import { describe, expect, it } from 'vitest'
import { searchFolded, type SearchChapter } from './search'

describe('searchFolded', () => {
  const chapters: SearchChapter[] = [
    {
      index: 0,
      text: 'Tiêu đề: Mở đầu cuộc hành trình tu tiên của Hàn Lập tại Thất Huyền Môn.',
    },
    {
      index: 1,
      text: 'Trọng phản cố địa Hư thiên điện. Ma diễm ngút trời, tiếng sấm ầm vang khắp nơi.',
    },
    {
      index: 2,
      text: 'Hàn Lập nhìn về phía xa. Lại gặp lại người quen cũ tại Hàn Ngọc cốc.',
    },
  ]

  it('tìm thấy chính xác cả khi gõ không dấu và có dấu', () => {
    // Tìm không dấu "han lap"
    const resNoAccent = searchFolded(chapters, 'han lap')
    expect(resNoAccent.length).toBe(2)
    expect(resNoAccent[0].chapterIndex).toBe(0)
    expect(resNoAccent[0].snippet).toContain('Hàn Lập')
    expect(resNoAccent[1].chapterIndex).toBe(2)

    // Tìm có dấu "Hư thiên điện"
    const resWithAccent = searchFolded(chapters, 'Hư thiên điện')
    expect(resWithAccent.length).toBe(1)
    expect(resWithAccent[0].chapterIndex).toBe(1)
    expect(resWithAccent[0].offset).toBe(18) // "Trọng phản cố địa ".length === 18
  })

  it('giới hạn số kết quả (limit)', () => {
    const res = searchFolded(chapters, 'Hàn Lập', 1)
    expect(res.length).toBe(1)
    expect(res[0].chapterIndex).toBe(0)
  })

  it('tạo snippet chính xác kèm dấu ba chấm …', () => {
    const res = searchFolded(chapters, 'ngút trời')
    expect(res.length).toBe(1)
    expect(res[0].snippet).toContain('ngút trời')
    expect(res[0].snippet).toContain('…')
  })

  it('trả về rỗng khi query rỗng hoặc toàn khoảng trắng', () => {
    expect(searchFolded(chapters, '')).toEqual([])
    expect(searchFolded(chapters, '   ')).toEqual([])
  })
})
