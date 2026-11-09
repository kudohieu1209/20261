// @vitest-environment happy-dom
import { existsSync, readFileSync } from 'node:fs'
import { strToU8, zipSync } from 'fflate'
import { describe, expect, it } from 'vitest'
import { parseEpub } from './parseEpub'

const chapterHtml = (title: string, part: string | null, paras: string[]) => `<?xml version="1.0" encoding="utf-8"?>
<html xmlns="http://www.w3.org/1999/xhtml"><head><title>${title}</title></head><body>
<div class="header">Truyện Thử</div>
<div class="author"><a href="https://example.com"><b>EXAMPLE.COM</b></a></div>
${part ? `<div class="part">${part}</div>` : ''}
<h4>${title}</h4>
${paras.map((p) => `<p>${p}</p>`).join('\n')}
</body></html>`

function buildEpub(): Uint8Array {
  return zipSync({
    mimetype: strToU8('application/epub+zip'),
    'META-INF/container.xml': strToU8(
      '<container><rootfiles><rootfile full-path="OEBPS/content.opf"/></rootfiles></container>',
    ),
    'OEBPS/content.opf': strToU8(`<?xml version="1.0"?>
<package xmlns="http://www.idpf.org/2007/opf" version="2.0">
  <metadata xmlns:dc="http://purl.org/dc/elements/1.1/">
    <dc:title>Truyện Thử</dc:title><dc:creator>Tác Giả</dc:creator>
    <meta name="cover" content="cover"/>
  </metadata>
  <manifest>
    <item id="ncx" href="toc.ncx" media-type="application/x-dtbncx+xml"/>
    <item id="cover" href="Images/cover.jpg" media-type="image/jpeg"/>
    <item id="mucluc" href="Text/mucluc.html" media-type="application/xhtml+xml"/>
    <item id="c0" href="Text/C0.html" media-type="application/xhtml+xml"/>
    <item id="c1" href="Text/C1.html" media-type="application/xhtml+xml"/>
    <item id="c2" href="Text/C2.html" media-type="application/xhtml+xml"/>
  </manifest>
  <spine toc="ncx"><itemref idref="mucluc"/><itemref idref="c0"/><itemref idref="c1"/><itemref idref="c2"/></spine>
</package>`),
    'OEBPS/toc.ncx': strToU8(`<ncx><navMap>
  <navPoint><navLabel><text>Mục lục</text></navLabel><content src="Text/mucluc.html"/></navPoint>
  <navPoint><navLabel><text>Chương 1: Sơn Biên Tiểu Thôn</text></navLabel><content src="Text/C0.html"/></navPoint>
  <navPoint><navLabel><text>Chương 2: Thanh Ngưu Trấn</text></navLabel><content src="Text/C1.html#x"/></navPoint>
  <navPoint><navLabel><text>Chương 3: Thất Huyền Môn</text></navLabel><content src="Text/C2.html"/></navPoint>
</navMap></ncx>`),
    'OEBPS/Images/cover.jpg': new Uint8Array([0xff, 0xd8, 0xff]),
    'OEBPS/Text/mucluc.html': strToU8(
      `<html><body><h4>Mục lục</h4><div><a href="C0.html">Chương 1: Sơn Biên Tiểu Thôn</a></div><div><a href="C1.html">Chương 2: Thanh Ngưu Trấn</a></div></body></html>`,
    ),
    'OEBPS/Text/C0.html': strToU8(chapterHtml('Chương 1: Sơn Biên Tiểu Thôn', 'Quyển 1', ['第一章 山边小村', 'Đoạn một.', '  Đoạn   hai.  '])),
    'OEBPS/Text/C1.html': strToU8(chapterHtml('Chương 2: Thanh Ngưu Trấn', 'Quyển 1', ['Đoạn ba.'])),
    'OEBPS/Text/C2.html': strToU8(chapterHtml('Chương 3: Thất Huyền Môn', 'Quyển 2', ['Đoạn bốn.'])),
  })
}

describe('parseEpub', () => {
  it('đọc metadata, ảnh bìa, quyển và chương', async () => {
    const book = await parseEpub(buildEpub())
    expect(book.title).toBe('Truyện Thử')
    expect(book.author).toBe('Tác Giả')
    expect(book.cover?.mime).toBe('image/jpeg')

    expect(book.volumes.map((v) => v.label)).toEqual(['Quyển 1', 'Quyển 2'])
    expect(book.chapters).toHaveLength(3) // trang mục lục bị bỏ qua
    expect(book.chapters[0]).toMatchObject({
      label: 'Chương 1',
      title: 'Sơn Biên Tiểu Thôn',
      originalTitle: '第一章 山边小村',
      volumeIndex: 0,
      text: 'Đoạn một.\nĐoạn hai.', // bỏ header/tác giả/link nguồn, gom khoảng trắng
    })
    expect(book.chapters[1]).toMatchObject({ label: 'Chương 2', volumeIndex: 0, text: 'Đoạn ba.' })
    expect(book.chapters[2]).toMatchObject({ label: 'Chương 3', volumeIndex: 1 })
    expect(book.totalChars).toBe(book.chapters.reduce((n, c) => n + c.text.length, 0))
  })
})

// Test trên file thật: EPUB_SAMPLE=/đường/dẫn/file.epub npm test
const real = process.env.EPUB_SAMPLE
describe.skipIf(!real || !existsSync(real))('parseEpub (file thật)', () => {
  it('đọc được toàn bộ', async () => {
    const t0 = performance.now()
    const b = await parseEpub(new Uint8Array(readFileSync(real!)))
    const ms = Math.round(performance.now() - t0)
    console.log(
      `${b.title} — ${b.author}: ${b.chapters.length} chương, ${b.volumes.length} quyển, ` +
        `${(b.totalChars / 1e6).toFixed(1)} triệu ký tự, ${ms} ms`,
    )
    console.log('quyển:', b.volumes.map((v) => v.label).join(', '))
    console.log('đầu:', b.chapters.slice(0, 2).map((c) => `${c.label}: ${c.title} | ${c.text.slice(0, 60)}`))
    console.log('cuối:', b.chapters.slice(-1).map((c) => `${c.label}: ${c.title} | ${c.text.slice(0, 60)}`))
    const empty = b.chapters.filter((c) => c.text.length < 200)
    console.log('chương ngắn bất thường:', empty.length, empty.slice(0, 5).map((c) => c.label))
    expect(b.chapters.length).toBeGreaterThan(100)
  }, 300_000)
})
