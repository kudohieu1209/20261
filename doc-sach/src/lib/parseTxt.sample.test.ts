// Test trên file mẫu lớn (tạo bằng `npm run sample`). Bỏ qua nếu chưa có file.
import { existsSync, readFileSync } from 'node:fs'
import { expect, it } from 'vitest'
import { decodeText, parseTxt } from './parseTxt'

const FILE = 'samples/truyen-mau.txt'

it.skipIf(!existsSync(FILE))('tách đúng 1300 chương / 10 quyển của file mẫu', () => {
  const t0 = performance.now()
  const b = parseTxt(decodeText(new Uint8Array(readFileSync(FILE))))
  const ms = performance.now() - t0
  console.log(`parse ${Math.round(ms)} ms, ${b.chapters.length} mục, ${b.totalChars} ký tự`)

  expect(b.volumes).toHaveLength(10)
  expect(b.volumes.every((v) => v.originalTitle?.startsWith('第'))).toBe(true)
  expect(b.chapters[0].label).toBe('Giới thiệu')
  expect(b.chapters).toHaveLength(1301)
  expect(b.chapters.slice(1).every((c, i) => c.label === `Chương ${i + 1}`)).toBe(true)
  expect(b.chapters[1300].volumeIndex).toBe(9)
  expect(ms).toBeLessThan(5000)
})
