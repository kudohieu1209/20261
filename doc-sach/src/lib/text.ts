/** Bỏ dấu tiếng Việt + chữ thường, để tìm kiếm không phân biệt dấu: "Hàn Lập" → "han lap". */
export function foldVi(s: string): string {
  return s
    .normalize('NFD')
    .replace(/[̀-ͯ]/g, '')
    .replace(/đ/g, 'd')
    .replace(/Đ/g, 'D')
    .toLowerCase()
}

/** true nếu `haystack` chứa `query` (bỏ qua dấu, hoa/thường). */
export function matchesVi(haystack: string, query: string): boolean {
  return foldVi(haystack).includes(foldVi(query.trim()))
}

/** Cache ánh xạ ký tự > 127 về ký tự thường không dấu tương ứng có độ dài đúng 1. */
const charCache = new Map<string, string>()

/**
 * Bỏ dấu nhưng GIỮ NGUYÊN ĐỘ DÀI CHUỖI (mỗi ký tự thành đúng 1 ký tự).
 * Nhờ vậy vị trí (index) tìm thấy trong chuỗi đã bỏ dấu chính là vị trí trong văn bản gốc.
 * Đầu vào nên được chuẩn hoá NFC trước để các ký tự tiếng Việt là 1 code unit.
 */
export function foldViSameLength(s: string): string {
  let out = ''
  for (let i = 0; i < s.length; i++) {
    const c = s[i]
    const code = c.charCodeAt(0)
    if (code <= 127) {
      out += code >= 65 && code <= 90 ? String.fromCharCode(code + 32) : c
    } else {
      let mapped = charCache.get(c)
      if (mapped === undefined) {
        if (c === 'đ' || c === 'Đ') {
          mapped = 'd'
        } else {
          const nfd = c.normalize('NFD')
          mapped = nfd[0].toLowerCase()
        }
        charCache.set(c, mapped)
      }
      out += mapped
    }
  }
  return out
}
