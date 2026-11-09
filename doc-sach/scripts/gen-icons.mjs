import fs from 'node:fs'
import path from 'node:path'
import zlib from 'node:zlib'

function makePng(width, height, drawFn) {
  const crcTable = new Uint32Array(256)
  for (let i = 0; i < 256; i++) {
    let c = i
    for (let j = 0; j < 8; j++) c = c & 1 ? 0xedb88320 ^ (c >>> 1) : c >>> 1
    crcTable[i] = c
  }
  function crc32(buf) {
    let c = 0xffffffff
    for (let i = 0; i < buf.length; i++) c = crcTable[(c ^ buf[i]) & 0xff] ^ (c >>> 8)
    return (c ^ 0xffffffff) >>> 0
  }
  function chunk(type, data) {
    const t = Buffer.from(type)
    const len = Buffer.alloc(4)
    len.writeUInt32BE(data.length)
    const td = Buffer.concat([t, data])
    const crc = Buffer.alloc(4)
    crc.writeUInt32BE(crc32(td))
    return Buffer.concat([len, td, crc])
  }

  const rowSize = 1 + width * 4
  const raw = Buffer.alloc(height * rowSize)
  for (let y = 0; y < height; y++) {
    const rowOffset = y * rowSize
    raw[rowOffset] = 0
    for (let x = 0; x < width; x++) {
      const pxOffset = rowOffset + 1 + x * 4
      const [r, g, b, a] = drawFn(x, y, width, height)
      raw[pxOffset] = r
      raw[pxOffset + 1] = g
      raw[pxOffset + 2] = b
      raw[pxOffset + 3] = a
    }
  }

  const ihdr = Buffer.alloc(13)
  ihdr.writeUInt32BE(width, 0)
  ihdr.writeUInt32BE(height, 4)
  ihdr[8] = 8
  ihdr[9] = 6
  ihdr[10] = 0
  ihdr[11] = 0
  ihdr[12] = 0

  const sig = Buffer.from([0x89, 0x50, 0x4e, 0x47, 0x0d, 0x0a, 0x1a, 0x0a])
  const idat = chunk('IDAT', zlib.deflateSync(raw))
  const iend = chunk('IEND', Buffer.alloc(0))
  return Buffer.concat([sig, chunk('IHDR', ihdr), idat, iend])
}

// Hàm vẽ biểu tượng cuốn sách
function bookDrawer(isMaskable) {
  return (x, y, w, h) => {
    // Tọa độ chuẩn hóa 0..1
    const nx = x / w
    const ny = y / h

    // Nền trắng
    const bg = [255, 255, 255, 255]
    const ink = [29, 29, 31, 255] // #1d1d1f

    // Vùng vẽ cuốn sách ở giữa
    const scale = isMaskable ? 0.65 : 0.8
    const cx = (nx - 0.5) / scale + 0.5
    const cy = (ny - 0.5) / scale + 0.5

    if (cx < 0.15 || cx > 0.85 || cy < 0.2 || cy > 0.8) {
      return bg
    }

    const midX = 0.5
    const spineDist = Math.abs(cx - midX)

    // Đường gáy giữa
    if (spineDist < 0.015 && cy >= 0.28 && cy <= 0.72) {
      return ink
    }

    // Các đường viền trang sách (trái và phải)
    // Đường cong trên: cy = 0.32 - curve
    const curve = Math.sin(spineDist * Math.PI * 1.5) * 0.05
    const topY = 0.35 - curve
    const bottomY = 0.75 - curve

    // Viền trên hoặc dưới
    if (Math.abs(cy - topY) < 0.02 || Math.abs(cy - bottomY) < 0.02) {
      if (spineDist >= 0.01 && spineDist <= 0.3) {
        return ink
      }
    }

    // Mép ngoài
    if (Math.abs(spineDist - 0.3) < 0.018 && cy >= topY && cy <= bottomY) {
      return ink
    }

    return bg
  }
}

const publicDir = path.resolve('public')
if (!fs.existsSync(publicDir)) {
  fs.mkdirSync(publicDir, { recursive: true })
}

fs.writeFileSync(path.join(publicDir, 'pwa-192x192.png'), makePng(192, 192, bookDrawer(false)))
fs.writeFileSync(path.join(publicDir, 'pwa-512x512.png'), makePng(512, 512, bookDrawer(false)))
fs.writeFileSync(path.join(publicDir, 'maskable-icon-512x512.png'), makePng(512, 512, bookDrawer(true)))
fs.writeFileSync(path.join(publicDir, 'apple-touch-icon.png'), makePng(180, 180, bookDrawer(false)))

console.log('Đã tạo thành công các icon PNG cho PWA!')
