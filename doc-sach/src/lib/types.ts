export type BookStatus = 'to_read' | 'reading' | 'finished'
export type BookFormat = 'txt' | 'epub'

/** Một dòng trong bảng `books` trên Supabase. */
export interface Book {
  id: string
  user_id: string
  title: string
  author: string | null
  file_path: string
  file_format: BookFormat
  /** ảnh bìa trong bucket "books" (null = không có) */
  cover_path: string | null
  parser_version: number
  status: BookStatus
  chapter_count: number
  total_chars: number
  started_at: string | null
  finished_at: string | null
  rating: number | null
  review: string | null
  created_at: string
  updated_at: string
}

/** Một dòng trong bảng `progress`. Vị trí neo theo ký tự, không theo số trang. */
export interface Progress {
  book_id: string
  chapter_index: number
  char_offset: number
  /** 0..1 trên toàn bộ sách */
  percent: number
  updated_at: string
}

export interface Volume {
  index: number
  /** "Quyển 7" */
  label: string
  /** "Tung hoành Nhân giới" (có thể rỗng) */
  title: string
  /** "第七卷 纵横人界" nếu file có kèm */
  originalTitle: string | null
}

export interface Chapter {
  index: number
  volumeIndex: number | null
  /** "Chương 1125", hoặc "Giới thiệu" cho phần mở đầu */
  label: string
  /** "Trọng phản cố địa Hư thiên điện" (có thể rỗng) */
  title: string
  originalTitle: string | null
  /** Các đoạn văn, ngăn cách bởi "\n" */
  text: string
  /** Vị trí ký tự đầu chương trên toàn sách (để tính % đọc) */
  charStart: number
}

export interface ParsedBook {
  volumes: Volume[]
  chapters: Chapter[]
  totalChars: number
}

/** Một dòng trong bảng `bookmarks`. */
export interface Bookmark {
  id: string
  user_id: string
  book_id: string
  chapter_index: number
  char_offset: number
  label: string | null
  created_at: string
  updated_at: string
}

/** Một dòng trong bảng `notes`. */
export interface Note {
  id: string
  user_id: string
  book_id: string
  chapter_index: number
  char_start: number
  char_end: number
  quote: string
  content: string | null
  color: string
  created_at: string
  updated_at: string
}
