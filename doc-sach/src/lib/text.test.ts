import { expect, it } from 'vitest'
import { foldVi, matchesVi } from './text'

it('tìm không dấu', () => {
  expect(foldVi('Trọng phản cố địa Hư thiên điện')).toBe('trong phan co dia hu thien dien')
  expect(matchesVi('Chương 1125: Trọng phản cố địa', 'co dia')).toBe(true)
  expect(matchesVi('Chương 1125', '1125')).toBe(true)
  expect(matchesVi('Đại Tấn', 'dai tan')).toBe(true)
})
