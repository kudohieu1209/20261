import { expect, it } from 'vitest'
import { foldVi, foldViSameLength, matchesVi } from './text'

it('tìm không dấu', () => {
  expect(foldVi('Trọng phản cố địa Hư thiên điện')).toBe('trong phan co dia hu thien dien')
  expect(matchesVi('Chương 1125: Trọng phản cố địa', 'co dia')).toBe(true)
  expect(matchesVi('Chương 1125', '1125')).toBe(true)
  expect(matchesVi('Đại Tấn', 'dai tan')).toBe(true)
})

it('foldViSameLength giữ nguyên độ dài chính xác từng ký tự', () => {
  const orig = 'Hàn Lập tiến nhập Cổ Ma Chi Địa!'
  const folded = foldViSameLength(orig)
  expect(folded).toBe('han lap tien nhap co ma chi dia!')
  expect(folded.length).toBe(orig.length)

  // Khớp vị trí index
  const query = 'co ma chi dia'
  const idx = folded.indexOf(query)
  expect(idx).toBe(18)
  expect(orig.slice(idx, idx + query.length)).toBe('Cổ Ma Chi Địa')

  // Giữ nguyên độ dài với chuỗi dấu tổ hợp sau khi chuẩn hoá NFC
  const nfdStr = 'Ha\u0300n Lâ\u0323p' // "Hàn Lập" dạng tổ hợp NFD
  const nfcStr = nfdStr.normalize('NFC')
  const foldedNfc = foldViSameLength(nfcStr)
  expect(foldedNfc).toBe('han lap')
  expect(foldedNfc.length).toBe(nfcStr.length)

  // Kiểm tra chữ hoa Đ và chữ thường đ
  expect(foldViSameLength('ĐƯỜNG ĐỜI')).toBe('duong doi')
  expect(foldViSameLength('đường đời')).toBe('duong doi')
})
