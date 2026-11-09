import { strFromU8, unzipSync } from 'fflate'
import { isHanLine, matchChapter, matchVolume } from './parseTxt'
import type { Chapter, ParsedBook, Volume } from './types'

export interface ParsedEpub extends ParsedBook {
  title: string | null
  author: string | null
  cover: { bytes: Uint8Array<ArrayBuffer>; mime: string } | null
}

interface TocEntry {
  label: string
  /** Nhãn mục cha trong mục lục (mục lục lồng 2 cấp: Quyển → Chương) */
  parent: string | null
}

const BLOCK_SELECTOR = 'p, div, li, blockquote, pre, h1, h2, h3, h4, h5, h6'
const HEADING_SELECTOR = 'h1, h2, h3, h4, h5, h6'

// ── tiện ích đường dẫn trong file zip ──────────────────────────────────────
const dirOf = (p: string) => (p.includes('/') ? p.slice(0, p.lastIndexOf('/') + 1) : '')
function resolvePath(base: string, href: string): string {
  const parts = (dirOf(base) + decodeURIComponent(href.split('#')[0])).split('/')
  const out: string[] = []
  for (const part of parts) {
    if (part === '..') out.pop()
    else if (part !== '.' && part !== '') out.push(part)
  }
  return out.join('/')
}

const clean = (s: string | null | undefined) => (s ?? '').replace(/\s+/g, ' ').trim()

function parseXml(text: string): Document {
  return new DOMParser().parseFromString(text, 'application/xml')
}
/** Tên thẻ bỏ tiền tố namespace: "dc:title" → "title". */
const localTag = (el: Element) => el.localName.slice(el.localName.indexOf(':') + 1)
/** Lấy phần tử theo tên, bỏ qua namespace (dc:title, opf:item...). */
const byTag = (root: Document | Element, tag: string) =>
  Array.from(root.getElementsByTagName('*')).filter((el) => localTag(el) === tag)
const childrenByTag = (el: Element, tag: string) => Array.from(el.children).filter((c) => localTag(c) === tag)

/** Đọc mục lục NCX (EPUB 2) hoặc nav (EPUB 3) → map đường dẫn file → nhãn. */
function readToc(files: Record<string, Uint8Array>, ncxPath: string | null, navPath: string | null): Map<string, TocEntry> {
  const toc = new Map<string, TocEntry>()
  if (ncxPath && files[ncxPath]) {
    const ncx = parseXml(strFromU8(files[ncxPath]))
    const walk = (points: Element[], parent: string | null) => {
      for (const np of points) {
        const navLabel = childrenByTag(np, 'navLabel')[0]
        const label = clean(navLabel ? childrenByTag(navLabel, 'text')[0]?.textContent : '')
        const src = childrenByTag(np, 'content')[0]?.getAttribute('src')
        if (src) {
          const path = resolvePath(ncxPath, src)
          if (!toc.has(path)) toc.set(path, { label, parent })
        }
        walk(childrenByTag(np, 'navPoint'), label)
      }
    }
    const navMap = byTag(ncx, 'navMap')[0]
    if (navMap) walk(childrenByTag(navMap, 'navPoint'), null)
  } else if (navPath && files[navPath]) {
    const doc = new DOMParser().parseFromString(strFromU8(files[navPath]), 'text/html')
    const nav = doc.querySelector('nav[epub\\:type="toc"], nav') ?? doc.body
    const walk = (ol: Element | null, parent: string | null) => {
      if (!ol) return
      for (const li of Array.from(ol.children).filter((c) => c.localName === 'li')) {
        const a = li.querySelector(':scope > a, :scope > span')
        const label = clean(a?.textContent)
        const href = a?.getAttribute('href')
        if (href) {
          const path = resolvePath(navPath, href)
          if (!toc.has(path)) toc.set(path, { label, parent })
        }
        walk(li.querySelector(':scope > ol'), label)
      }
    }
    walk(nav.querySelector('ol'), null)
  }
  return toc
}

/** Các khối chữ "lá" (không chứa khối con) theo thứ tự xuất hiện. */
function leafBlocks(root: Element): Element[] {
  return Array.from(root.querySelectorAll(BLOCK_SELECTOR)).filter((el) => !el.querySelector(BLOCK_SELECTOR))
}

const yieldToUi = () => new Promise<void>((r) => setTimeout(r, 0))

/**
 * Đọc file EPUB thành Quyển/Chương. Mỗi file HTML trong spine là một chương.
 * - Tên chương: lấy từ mục lục, không có thì lấy thẻ heading đầu tiên.
 * - Quyển: từ mục lục lồng 2 cấp, hoặc từ dòng "Quyển N" đứng trước heading trong chương.
 * - Phần trước heading (tên truyện, tác giả, link nguồn) bị bỏ qua.
 * - Trang mục lục / trang bìa (không có đoạn văn) bị bỏ qua.
 */
export async function parseEpub(
  data: Uint8Array,
  onProgress?: (done: number, total: number) => void,
): Promise<ParsedEpub> {
  const files = unzipSync(data)
  const read = (p: string) => (files[p] ? strFromU8(files[p]) : null)

  const container = read('META-INF/container.xml')
  const opfPath = container && /full-path="([^"]+)"/.exec(container)?.[1]
  if (!opfPath || !files[opfPath]) throw new Error('File EPUB hỏng: không tìm thấy content.opf')
  const opf = parseXml(read(opfPath)!)

  const title = clean(byTag(opf, 'title')[0]?.textContent) || null
  const author = clean(byTag(opf, 'creator')[0]?.textContent) || null

  const manifest = new Map<string, { path: string; type: string; props: string }>()
  for (const item of byTag(opf, 'item')) {
    manifest.set(item.getAttribute('id') ?? '', {
      path: resolvePath(opfPath, item.getAttribute('href') ?? ''),
      type: item.getAttribute('media-type') ?? '',
      props: item.getAttribute('properties') ?? '',
    })
  }

  // Ảnh bìa: <meta name="cover" content="id"> (EPUB 2) hoặc properties="cover-image" (EPUB 3)
  const coverRef = byTag(opf, 'meta').find((m) => m.getAttribute('name') === 'cover')?.getAttribute('content')
  const coverItem =
    (coverRef && (manifest.get(coverRef) ?? [...manifest.values()].find((m) => m.path.endsWith(coverRef)))) ||
    [...manifest.values()].find((m) => m.props.includes('cover-image'))
  const cover =
    coverItem && files[coverItem.path] && coverItem.type.startsWith('image/')
      ? { bytes: files[coverItem.path] as Uint8Array<ArrayBuffer>, mime: coverItem.type }
      : null

  const spineEl = byTag(opf, 'spine')[0]
  const ncxPath = manifest.get(spineEl?.getAttribute('toc') ?? '')?.path ?? null
  const navPath = [...manifest.values()].find((m) => m.props.split(/\s+/).includes('nav'))?.path ?? null
  const toc = readToc(files, ncxPath, navPath)

  const spine = byTag(opf, 'itemref')
    .filter((r) => r.getAttribute('linear') !== 'no')
    .map((r) => manifest.get(r.getAttribute('idref') ?? ''))
    .filter((m): m is NonNullable<typeof m> => !!m && /html/.test(m.type) && m.path !== navPath)

  const volumes: Volume[] = []
  const chapters: Chapter[] = []
  const parser = new DOMParser()

  const useVolume = (label: string, volTitle = '') => {
    const last = volumes[volumes.length - 1]
    if (last && last.label === label) return last.index
    volumes.push({ index: volumes.length, label, title: volTitle, originalTitle: null })
    return volumes.length - 1
  }

  for (let i = 0; i < spine.length; i++) {
    if (i % 100 === 0) {
      onProgress?.(i, spine.length)
      await yieldToUi()
    }
    const { path } = spine[i]
    const html = read(path)
    if (!html) continue
    // Chỉ phân tích <body>: bỏ <link>/<style>/<script> ở <head>, nhanh hơn và không tải gì từ ngoài.
    const bodyHtml = /<body[^>]*>([\s\S]*)<\/body>/i.exec(html)?.[1] ?? html
    const docTitle = clean(/<title[^>]*>([\s\S]*?)<\/title>/i.exec(html)?.[1])
    const body = parser.parseFromString(`<!doctype html><html><body>${bodyHtml}</body></html>`, 'text/html').body
    if (!body) continue

    const heading = body.querySelector(HEADING_SELECTOR)
    const blocks = leafBlocks(body)
    const headingIdx = heading ? blocks.indexOf(heading) : -1
    const before = headingIdx >= 0 ? blocks.slice(0, headingIdx) : []
    let paragraphs = (headingIdx >= 0 ? blocks.slice(headingIdx + 1) : blocks)
      .map((el) => clean(el.textContent))
      .filter(Boolean)

    // Bỏ trang mục lục: phần lớn chữ nằm trong link.
    const linkChars = Array.from(body.querySelectorAll('a')).reduce((n, a) => n + clean(a.textContent).length, 0)
    const allChars = clean(body.textContent).length
    if (paragraphs.length === 0 || (allChars > 0 && linkChars / allChars > 0.5)) continue

    // Quyển
    const entry = toc.get(path)
    let volumeIndex: number | null = volumes.length ? volumes.length - 1 : null
    const tocVolume = entry?.parent ? (matchVolume(entry.parent) ?? { label: entry.parent, title: '' }) : null
    const markerVolume = before.map((el) => matchVolume(clean(el.textContent))).find(Boolean) ?? null
    const vol = tocVolume ?? markerVolume
    if (vol) volumeIndex = useVolume(vol.label, vol.title)

    // Chương
    const rawTitle = (entry?.label || clean(heading?.textContent) || docTitle || `Mục ${chapters.length + 1}`)
      .replace(/\s*[:：]\s*$/, '')
    const ch = matchChapter(rawTitle)
    let originalTitle: string | null = null
    if (paragraphs[0] && isHanLine(paragraphs[0])) {
      originalTitle = paragraphs[0]
      paragraphs = paragraphs.slice(1)
    }

    chapters.push({
      index: chapters.length,
      volumeIndex,
      label: ch ? ch.label : rawTitle,
      title: ch ? ch.title : '',
      originalTitle,
      text: paragraphs.join('\n'),
      charStart: 0,
    })
  }
  onProgress?.(spine.length, spine.length)

  let offset = 0
  for (const ch of chapters) {
    ch.charStart = offset
    offset += ch.text.length
  }
  return { title, author, cover, volumes, chapters, totalChars: offset }
}
