#!/usr/bin/env node
// Sinh một bộ "truyện" giả dạng TXT để test tách chương / chia trang / tìm kiếm.
// Dùng: node scripts/gen-sample-book.mjs [số_chương=1300] [file_ra=samples/truyen-mau.txt]
import { mkdirSync, writeFileSync } from 'node:fs'
import { dirname } from 'node:path'

const totalChapters = Number(process.argv[2] ?? 1300)
const out = process.argv[3] ?? 'samples/truyen-mau.txt'

// Bộ sinh số ngẫu nhiên có seed → lần nào chạy cũng ra cùng một file.
let seed = 20261109
const rand = () => ((seed = (seed * 1103515245 + 12345) % 2 ** 31) / 2 ** 31)
const pick = (arr) => arr[Math.floor(rand() * arr.length)]
const between = (a, b) => a + Math.floor(rand() * (b - a + 1))

const names = ['Hàn Lập', 'Trần Bình An', 'Ninh Diêu', 'Lý Hóa Nguyên', 'Nam Cung Uyển', 'Tề Tĩnh Xuân', 'Mặc đại phu']
const verbs = ['khẽ gật đầu', 'trầm ngâm hồi lâu', 'nhíu mày', 'mỉm cười', 'thu lại pháp bảo', 'vận chuyển linh lực', 'ngẩng đầu nhìn trời']
const places = ['Thất Huyền Môn', 'Hoàng Phong Cốc', 'Loạn Tinh Hải', 'Đại Tấn', 'Thiên Nam', 'Ly Châu động thiên', 'Kiếm Khí Trường Thành']
const things = ['tam sắc hỏa diễm', 'một khối lệnh bài màu lam', 'thanh phi kiếm', 'cổ truyền tống trận', 'quyển sách cổ', 'bình đan dược', 'tấm ngọc giản']
const tails = [
  'quang mang chói mắt tán loạn vỡ vụn ra.',
  'trong lòng không khỏi thầm kinh hãi.',
  'mọi chuyện dường như đã được định sẵn từ trước.',
  'gió núi thổi qua, mang theo hơi lạnh thấu xương.',
  'hắn biết rằng con đường phía trước vẫn còn rất dài.',
]
const han = '天地玄黄宇宙洪荒日月盈昃辰宿列张寒来暑往秋收冬藏'
const hanTitle = (n) => Array.from({ length: n }, () => han[between(0, han.length - 1)]).join('')

function sentence() {
  const s = `${pick(names)} ${pick(verbs)}, ${pick(['tại', 'giữa', 'bên ngoài'])} ${pick(places)} lấy ra ${pick(things)}, ${pick(tails)}`
  return rand() < 0.2 ? `"${s}"` : s
}
const paragraph = () => Array.from({ length: between(2, 6) }, sentence).join(' ')

const volumeTitles = ['Lung Trung Tước', 'Sơn Thủy Lang', 'Kim Thác Đao', 'Kiếm Khí Cận', 'Đạo Quan Đạo', 'Tiểu Phu Tử', 'Tung hoành Nhân giới', 'Tư Vô Tà', 'Thiên Thượng Nguyệt', 'Viễn Du Khách']
const chaptersPerVolume = Math.ceil(totalChapters / volumeTitles.length)

const lines = [
  'TRUYỆN MẪU ĐỂ TEST',
  'Tác giả: Không Tên',
  '',
  paragraph(),
  paragraph(),
  '',
]

for (let c = 1; c <= totalChapters; c++) {
  if ((c - 1) % chaptersPerVolume === 0) {
    const v = (c - 1) / chaptersPerVolume + 1
    lines.push('', `Quyển ${v}: ${volumeTitles[v - 1] ?? 'Không tên'}`, `第${v}卷 ${hanTitle(4)}`, '')
  }
  // Trộn vài kiểu viết tiêu đề để test bộ tách chương.
  const style = c % 17 === 0 ? `chuong ${c} - ` : c % 23 === 0 ? `Chương ${c}. ` : `Chương ${c}: `
  lines.push('', `${style}${pick(names)} ${pick(['đến', 'rời', 'trở lại'])} ${pick(places)}`)
  if (rand() < 0.5) lines.push(`第${c}章 ${hanTitle(between(3, 6))}`)
  lines.push('')
  for (let p = between(12, 30); p > 0; p--) lines.push('    ' + paragraph())
}

mkdirSync(dirname(out), { recursive: true })
const text = lines.join('\r\n')
writeFileSync(out, '﻿' + text, 'utf8')
console.log(`Đã ghi ${out}: ${totalChapters} chương, ${(Buffer.byteLength(text) / 1024 / 1024).toFixed(1)} MB`)
