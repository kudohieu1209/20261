import { describe, expect, it } from 'vitest'
import { decodeText, parseTxt } from './parseTxt'

const SAMPLE = `﻿Phàm Nhân Tu Tiên
Tác giả: Vong Ngữ

Quyển 1: Thất Huyền Môn
第一卷 七玄门

Chương 1: Sơn biên tiểu thôn
第一章 山边小村

Đoạn một.
   Đoạn hai, có khoảng trắng đầu dòng.

chuong 2 - Thanh Ngưu trấn
Hồi 3 giờ sáng, hắn tỉnh dậy.
Tập 2 người đi trước.
Quyển 2 Tung hoành
Chương 3
Nội dung chương ba.
`

describe('parseTxt', () => {
  const book = parseTxt(SAMPLE)

  it('tách phần giới thiệu trước chương đầu', () => {
    expect(book.chapters[0].label).toBe('Giới thiệu')
    expect(book.chapters[0].text).toBe('Phàm Nhân Tu Tiên\nTác giả: Vong Ngữ')
    expect(book.chapters[0].volumeIndex).toBeNull()
  })

  it('nhận quyển kèm tên gốc chữ Hán', () => {
    expect(book.volumes).toHaveLength(2)
    expect(book.volumes[0]).toMatchObject({
      label: 'Quyển 1',
      title: 'Thất Huyền Môn',
      originalTitle: '第一卷 七玄门',
    })
    expect(book.volumes[1]).toMatchObject({ label: 'Quyển 2', title: 'Tung hoành' })
  })

  it('nhận chương với nhiều kiểu viết', () => {
    const [, c1, c2, c3] = book.chapters
    expect(c1).toMatchObject({ label: 'Chương 1', title: 'Sơn biên tiểu thôn', originalTitle: '第一章 山边小村', volumeIndex: 0 })
    expect(c1.text).toBe('Đoạn một.\nĐoạn hai, có khoảng trắng đầu dòng.')
    expect(c2).toMatchObject({ label: 'Chương 2', title: 'Thanh Ngưu trấn', volumeIndex: 0 })
    expect(c3).toMatchObject({ label: 'Chương 3', title: '', volumeIndex: 1 })
  })

  it('không nhận nhầm câu văn là tiêu đề', () => {
    expect(book.chapters[2].text).toBe('Hồi 3 giờ sáng, hắn tỉnh dậy.\nTập 2 người đi trước.')
  })

  it('tính vị trí ký tự liên tục trên toàn sách', () => {
    let offset = 0
    for (const ch of book.chapters) {
      expect(ch.charStart).toBe(offset)
      offset += ch.text.length
    }
    expect(book.totalChars).toBe(offset)
    expect(book.chapters.map((c) => c.index)).toEqual([0, 1, 2, 3])
  })

  it('bỏ qua phần giới thiệu nếu file bắt đầu ngay bằng chương', () => {
    const b = parseTxt('Chương 1: A\nx\nChương 2: B\ny')
    expect(b.chapters.map((c) => c.label)).toEqual(['Chương 1', 'Chương 2'])
  })
})

describe('decodeText', () => {
  it('đọc UTF-8 có BOM và UTF-16LE', () => {
    const utf8 = new TextEncoder().encode('﻿Hàn Lập')
    expect(decodeText(utf8).replace(/^﻿/, '')).toBe('Hàn Lập')
    const s = 'Hàn Lập'
    const u16 = new Uint8Array(2 + s.length * 2)
    u16.set([0xff, 0xfe])
    for (let i = 0; i < s.length; i++) {
      u16[2 + i * 2] = s.charCodeAt(i) & 0xff
      u16[3 + i * 2] = s.charCodeAt(i) >> 8
    }
    expect(decodeText(u16)).toBe('Hàn Lập')
  })
})
