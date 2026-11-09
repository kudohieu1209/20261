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
