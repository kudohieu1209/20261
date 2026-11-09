# Brief giao diện — app Đọc sách

> Dành cho agent làm giao diện (Antigravity). Đọc kỹ toàn bộ tài liệu trước khi sửa code.

## 0. Bối cảnh và phân công

- App đọc sách cá nhân (một người dùng), tối ưu cho **tablet Android / iPad màn hình ngang** và hỗ trợ mượt mà **điện thoại dọc**.
- Quy mô truyện: 1.500–2.500 chương, 20–25 triệu ký tự (truyện tiên hiệp, tiểu thuyết dịch dài kỳ).
- **Toàn bộ logic đã hoàn tất 100%**:
  1. Đăng nhập Supabase, đồng bộ outbox offline-first.
  2. Nhập EPUB/TXT, tách chương chuẩn Unicode NFC, cache IndexedDB (Dexie).
  3. Lật 2 trang / 1 trang (`usePaginator`, CSS multi-column) chuẩn xác từng ký tự, tính tổng trang toàn sách lúc rảnh.
  4. Dấu trang + Ghi chú / Highlight 4 màu (`useAnnotations`, đồng bộ Supabase).
  5. Tìm kiếm toàn văn cả triệu chữ qua Web Worker, gõ không dấu vẫn ra kết quả kèm trích đoạn (`useBookSearch`).
  6. Đọc to (TTS) giọng tiếng Việt Web Speech API, tự động sang trang, đổi chương (`useTts`).
  7. PWA cài đặt offline, Service Worker precache shell + font, prompt cài app (`useInstallPrompt`).
  8. Giữ Supabase không ngủ định kỳ qua GitHub Actions.
- **Việc của agent giao diện**: biến giao diện khung (placeholder) thành trải nghiệm đọc cao cấp, tinh tế, mượt mà chuẩn phong cách Apple.

### Được làm
- Viết lại JSX và CSS của `src/pages/*.tsx`; tạo component trong `src/components/**`, style trong `src/styles/**`.
- Dùng **CSS Modules** (`*.module.css`) và các biến thiết kế trong `src/styles/tokens.css`.
- Cài `lucide-react` để lấy icon (nét 1.5px, cỡ 20px).
- Bổ sung biến token vào `tokens.css` nếu thật sự cần (ghi chú lý do cạnh biến).

### Không được làm
- **Không sửa `src/lib/**`, `src/hooks/**`, `src/workers/**`, `supabase/**`.** Nếu cần thêm hàm hoặc dữ liệu, ghi vào mục 5 ("Yêu cầu cho phần logic").
- Không cài Tailwind, UI kit cồng kềnh (MUI, Chakra...), hoặc thư viện animation nặng.
- Không hard-code mã màu `#...`, bo góc, độ dày bóng. Mọi giá trị giao diện dùng `var(--...)`.
- **Bảng màu:** Đen – trắng – xám làm chủ đạo. Điểm nhấn là 4 màu highlight đọc sách tinh tế (vàng, hổ phách, xám, đá phiến) và `--color-danger` (chỉ cho nút Xóa).

---

## 1. Phong cách thiết kế & Animation chuẩn Apple

Hình dung giao diện tinh xảo của **Apple Books**, **Safari Reader** và **iPadOS**: mềm mại, sạch sẽ, khoảng thở rộng rãi và phản hồi xúc giác mượt mà.

| Yếu tố | Quy tắc |
|---|---|
| Theme | Nền trang trắng ngà dịu mắt `--color-page` (#fcfbf9), khối nổi `--color-surface` (#f5f5f7), nền app `--color-bg` (#ffffff). |
| Màu chữ | Chữ đọc sách `--color-page-text` (#2c2c2e), chữ phụ `--color-page-muted` (#8e8e93). |
| Bo góc | Nút bấm `--radius-md` (10px), thẻ `--radius-lg` (16px), modal/sheet `--radius-xl` (24px), nút icon tròn `--radius-full` (9999px). |
| Bóng đổ | `--shadow-sm`, `--shadow-md`, `--shadow-lg` lan tỏa nhẹ tự nhiên. Dùng viền siêu mảnh `--color-border` (rgba 8% đen). |
| Kính mờ (Glassmorphism) | `background: var(--glass-bg); backdrop-filter: var(--glass-blur); -webkit-backdrop-filter: var(--glass-blur);` |
| Vùng chạm (Touch target) | Tối thiểu **44×44px** cho mọi nút bấm, icon thao tác trên màn cảm ứng. |
| Ngôn ngữ | Toàn bộ giao diện hiển thị bằng **tiếng Việt**. |

### Chuyển động (Animation Tokens)
Mọi hiệu ứng chuyển cảnh phải sử dụng các token sau:
- Đường cong Apple Spring: `--ease-apple: cubic-bezier(0.32, 0.72, 0, 1)`
- Modal & Sheet Elastic Spring: `--ease-spring: cubic-bezier(0.175, 0.885, 0.32, 1.15)`
- Thời lượng:
  - Lật trang: `--duration-page-turn` (320ms)
  - Bottom sheet & Modal: `--duration-sheet` (400ms)
  - Floating Popover / Pill: `--duration-popover` (200ms)
  - Tương tác nhanh: `--duration-fast` (150ms)
- Tương tác nhấn: Nút bấm có hiệu ứng lún nhẹ khi bấm giữ: `transform: scale(0.97)`
- Trợ năng: Khi người dùng bật `prefers-reduced-motion`, token tự động giảm thời lượng về `0s` và bỏ scale.

### Font chữ
- **Nội dung đọc & tiêu đề sách**: `var(--font-book)` = **Libertinus Serif** (font chuẩn sách in có sẵn tiếng Việt đầy đủ).
- **Giao diện người dùng (UI)**: `var(--font-ui)` = SF Pro / Inter.
- **Tên chữ Hán gốc**: `var(--font-cjk)`.

---

## 2. Chi tiết các màn hình

### 2.1 Đăng nhập (`LoginPage`)
- Card trắng trung tâm, `--radius-xl`, `--shadow-lg`, nền `--color-surface`.
- Tên app "Đọc sách" font serif lớn `--text-3xl`.
- 2 ô input (email, mật khẩu) bo góc `--radius-md`, cao 48px, không viền, nền xám nhạt.
- Nút "Đăng nhập" đen bo góc, rộng 100%, hiệu ứng `:active` co nhẹ.
- Lỗi đăng nhập hiển thị chữ nhỏ màu đỏ dưới nút.

### 2.2 Thư viện (`LibraryPage`)
Dữ liệu từ `useLibrary()` và `useInstallPrompt()`.
- **Header kính mờ**: Tiêu đề "Thư viện" kiểu Large Title iOS.
- **Nút "Cài app"**: Tự động hiển thị khi trình duyệt hỗ trợ PWA (`canInstall === true`), bấm vào gọi `promptInstall()`.
- **Nút "＋ Thêm sách"**: Nhận file `.epub` hoặc `.txt`. Khi đang import, chuyển sang trạng thái loading hiển thị từng bước: đọc file → tách chương (hiển thị % hoặc x/y chương) → tải lên → lưu cache.
- **Bìa sách & Phân nhóm**:
  1. *Đang đọc*: Thẻ ngang nổi bật, bìa tỉ lệ 2:3, tên sách, tác giả, thanh tiến độ mảnh, "Chương X · Y%" và nút "Đọc tiếp".
  2. *Muốn đọc*: Lưới bìa sách gọn gàng.
  3. *Đã đọc xong*: Lưới bìa, ghi ngày hoàn thành.
  - Sách không có bìa ảnh: Tự vẽ bìa typographic thanh lịch bằng CSS: nền `--color-surface`, tiêu đề font serif, đường chỉ mảnh, tên tác giả.
  - Menu context ("…"): Đổi trạng thái hoặc Xóa sách (dialog xác nhận tuỳ biến).

### 2.3 Màn hình đọc (`ReaderPage`) — Trung tâm ứng dụng
Dữ liệu từ `useReader`, `usePaginator`, `usePageTurnControls`, `useAnnotations`, `useTts`, `useBookSearch`.

#### Bố cục trang & Lật trang
- **2 trang đối xứng (spread)** khi màn ngang $\ge 900\text{px}$, có rãnh gáy sách `--color-page-gutter` ở giữa. Màn dọc hoặc hẹp tự động thành **1 trang**.
- Container phân trang bằng CSS multi-column (`column-width: var(--page-width)`, `column-gap: var(--page-gap)`).
- Lật trang bằng hiệu ứng dịch chuyển mượt: `transform: translateX(-...)`, transition dùng `--duration-page-turn` và `--ease-apple`.
- **Running Header / Footer**:
  - Đầu trang trái: Tên sách.
  - Đầu trang phải: Tên chương hiện tại.
  - Chân trang: Số trang toàn sách định dạng `[Trang X / Tổng Y]` (hoặc `%` nếu đang tính nền), và tiến độ phần trăm toàn sách.
- **Mở đầu chương**:
  - Tên Quyển (nếu có): Chữ hoa, giãn chữ (`letter-spacing: 0.2em`).
  - Tên chương lớn, hoa văn phân cách `——— ◆ ———`.
  - Drop cap: Chữ cái đầu tiên thụt cao 3 dòng.
- **Mỗi đoạn văn bắt buộc giữ thuộc tính `data-offset={p.start}`** để phục vụ việc định vị ký tự.

#### Ribbon Dấu trang (Bookmark Ribbon)
- Icon ribbon tinh tế ở góc trên bên phải trang sách.
- Khi trang hiện tại có dấu trang (`isBookmarked(pageRange) === true`), ribbon sáng màu rõ nét.
- Bấm vào ribbon để thêm/bỏ dấu trang (`toggleBookmark(pageRange)`).

#### Thanh công cụ chọn chữ (Selection Floating Toolbar)
- Khi bôi đen đoạn văn, thanh toolbar nổi kính mờ xuất hiện ngay phía trên vùng chọn:
  - 4 nút tròn màu highlight:
    - Vàng dịu: `--color-highlight-yellow` (#fff1a8)
    - Hổ phách: `--color-highlight-amber` (#fed7aa)
    - Xám khói: `--color-highlight-gray` (#e5e5ea)
    - Đá phiến: `--color-highlight-slate` (#cbd5e1)
  - Nút "Ghi chú": Mở popover/dialog nhập nội dung ghi chú cho trích dẫn đó.
  - Nút "Sao chép": Copy đoạn trích dẫn vào clipboard.
- Khi người dùng bấm vào một đoạn đã highlight trong sách: Mở popover xem/sửa ghi chú hoặc đổi màu / xoá highlight.

#### Thanh phát Đọc to (TTS Player Bar)
- Thanh điều khiển dạng viên thuốc (pill) nổi kính mờ ở dưới màn hình:
  - Nút Play / Pause / Stop.
  - Bộ chọn tốc độ: `0.8x`, `1.0x`, `1.2x`, `1.5x`, `2.0x`.
  - Bộ chọn giọng đọc tiếng Việt (`vi-VN`).
- **Highlight câu đang đọc**: Câu văn đang phát âm được tô sáng êm dịu (`ttsActive: true`), tự động lật trang khi đọc đến câu ở trang kế tiếp.

#### Điều khiển trang (`usePageTurnControls`)
- Vuốt chạm ngang (swipe > 40px).
- Chạm vùng: 30% mép trái (lùi trang), 30% mép phải (sang trang), 40% giữa (bật/tắt thanh công cụ trên/dưới).
- Phím bấm: Mũi tên trái/phải, Space, PageUp, PageDown.
- Bỏ qua chạm lật trang khi người dùng đang bôi đen chọn văn bản.

### 2.4 Modal Mục lục & Tìm kiếm (TOC Sheet)
Sheet nổi mở từ nút Mục lục trên thanh điều khiển.
Gồm 4 tab phân đoạn (Segmented Control):
1. **Chương**: Danh sách theo Quyển (gập/mở), hiển thị chương đang đọc, tự cuộn tới vị trí hiện tại. Sách không có Quyển thì gom nhóm 100 chương. Có ô lọc nhanh tiêu đề chương (không phân biệt dấu).
2. **Dấu trang ({n})**: Danh sách tất cả dấu trang của sách, kèm tên chương và trích đoạn. Bấm vào chuyển ngay tới trang chứa dấu.
3. **Ghi chú ({n})**: Danh sách các ghi chú, màu highlight, trích đoạn văn bản và lời ghi chú cá nhân. Bấm vào để nhảy đến vị trí đó trong sách.
4. **Tìm kiếm**:
   - Ô nhập tìm kiếm toàn bộ nội dung sách (hơn 2.000 chương).
   - Tự động debounce 300ms, tìm qua Web Worker không gây đơ giao diện.
   - Kết quả hiển thị kèm trích dẫn ngữ cảnh (~40 ký tự trước và sau từ khóa).
   - Bấm vào kết quả: Tự động chuyển tới chương và vị trí tương ứng, từ khóa được tô sáng tạm thời (`isSearchHit`).

---

## 3. Danh mục API & Hooks có sẵn

### `useLibrary()` (`src/hooks/useLibrary.ts`)
```ts
const {
  items,        // { book: Book; progress: Progress | null }[]
  loading, error,
  importing,    // null | { stage: 'reading'|'parsing'|'uploading'|'saving'; done?: number; total?: number }
  importFile,   // (file: File) => Promise<Book | null>
  changeStatus, // (book, 'to_read'|'reading'|'finished') => Promise<void>
  remove,       // (book) => Promise<void>
  refresh,
} = useLibrary()
```

### `useInstallPrompt()` (`src/hooks/useInstallPrompt.ts`)
```ts
const { canInstall, promptInstall } = useInstallPrompt()
// promptInstall(): Promise<boolean> — gọi khi người dùng bấm nút "Cài app"
```

### `useReader(bookId)` (`src/hooks/useReader.ts`)
```ts
const {
  book,          // Thông tin sách
  toc,           // { volumes: LocalVolume[]; chapters: ChapterMeta[] }
  chapter,       // ChapterMeta hiện tại
  paragraphs,    // { start: number; text: string }[] của chương
  restoreOffset, // number | 'end' | null — vị trí cần cuộn/lật tới
  percent,       // 0..1 tiến độ toàn sách
  loading, error,
  isLastChapter,
  goToChapter,   // (index: number, offset?: number | 'end') => void
  nextChapter,   // () => void
  prevChapter,   // () => void
  reportPosition,// (charOffset: number) => void — báo vị trí ký tự đang đọc
  markFinished,  // () => void
} = useReader(bookId)
```

### `usePaginator(options)` (`src/hooks/usePaginator.ts`)
```ts
const paginator = usePaginator({
  contentRef,      // Ref của thẻ div chứa các đoạn văn (multi-column)
  chapter,         // ChapterMeta hiện tại
  restoreOffset,   // restoreOffset từ useReader
  book,            // Book hiện tại
  onPageChange,    // (charOffset: number) => void — kết nối với reportPosition
  onNextChapter,   // () => void
  onPrevChapter,   // () => void
})
// paginator: {
//   page, pageCount, spread,
//   pageRange: { start: number; end: number },
//   globalPage: number | null,
//   totalPages: number | null,
//   next: () => void,
//   prev: () => void,
//   goToOffset: (offset: number) => void,
//   remeasure: () => void,
// }
```

### `usePageTurnControls(options)` (`src/hooks/usePageTurnControls.ts`)
```ts
usePageTurnControls({
  containerRef,
  onNext: paginator.next,
  onPrev: paginator.prev,
  onToggleChrome: () => setShowChrome(v => !v),
  enabled: true,
})
```

### `useAnnotations(bookId)` (`src/hooks/useAnnotations.ts`)
```ts
const {
  bookmarks,       // Bookmark[] (đã sắp xếp)
  notes,           // Note[] (đã sắp xếp)
  isBookmarked,    // (pageRange: { start: number; end: number } | null) => boolean
  toggleBookmark,  // (pageRange: { start: number; end: number } | null) => Promise<void>
  notesForChapter, // (chapterIndex: number) => Note[]
  addNote,         // ({ chapterIndex, start, end, quote, color, content }) => Promise<string>
  updateNote,      // (id, { color?, content? }) => Promise<void>
  removeNote,      // (id) => Promise<void>
} = useAnnotations(bookId)
```

### `useBookSearch(bookId)` (`src/hooks/useBookSearch.ts`)
```ts
const {
  query,        // string
  setQuery,     // (q: string) => void — tự debounce 300ms
  results,      // SearchResultItem[]: { chapterIndex, offset, length, snippet }
  searching,    // boolean
  total,        // number
} = useBookSearch(bookId)
```

### `useTts(options)` (`src/hooks/useTts.ts`)
```ts
const tts = useTts({
  paragraphs,
  chapterIndex: chapter.index,
  paginator,
  onNextChapter,
})
// tts: {
//   supported, playing, current, rate, voice, voices,
//   speakSentence: (index: number) => void,
//   togglePlay: () => void,
//   stop: () => void,
//   setRate: (rate: number) => void,
//   setVoice: (voiceUri: string) => void,
// }
```

### Helpers xử lý nội dung văn bản (`src/lib/annotations.ts`)
```ts
// Tách đoạn văn thành các mảnh chữ có màu highlight, kết quả search, hoặc TTS active
const segments = segmentParagraph(p, highlights)
// highlights: { start: number; end: number; noteId?: string; color?: string; ttsActive?: boolean; isSearchHit?: boolean }[]

// Chuyển vùng bôi đen (window.getSelection()) thành toạ độ ký tự chuẩn
const selection = selectionToRange(contentRef.current)
// trả về { chapterIndex, start, end, quote } hoặc null
```

---

## 4. Danh sách kiểm tra chất lượng (Checklist)

- [ ] `npm test`, `npm run build` và `npm run lint` chạy sạch sẽ không lỗi.
- [ ] Không hard-code màu `#...`, bo góc `px` (chỉ dùng `var(--...)`).
- [ ] Trải nghiệm tablet ngang (1200×750px) 2 trang sách có gáy ở giữa, tablet/điện thoại dọc (390×844px) 1 trang mượt mà.
- [ ] Lật trang mượt mà bằng phím mũi tên, vuốt cảm ứng, click mép trái/phải.
- [ ] Bôi đen chữ xuất hiện toolbar 4 màu highlight, thêm ghi chú và đồng bộ tức thì.
- [ ] Ribbon dấu trang ở góc trên bên phải phản hồi đúng trang đang mở.
- [ ] Tìm kiếm không dấu trên tiểu thuyết 2.500 chương hoạt động nhanh, bấm vào nhảy đúng dòng và tô sáng kết quả.
- [ ] Đọc to (TTS) giọng Việt mượt mà, câu đang đọc highlight rõ ràng, tự động chuyển trang/chương.
- [ ] Nút "Cài app" hoạt động trơn tru khi chạy dạng Web App / PWA.
- [ ] Tất cả nút bấm $\ge 44\times 44\text{px}$, hiệu ứng `:active` spring tự nhiên.

---

## 5. Yêu cầu cho phần logic

*(Agent giao diện ghi lại tại đây các hàm hoặc dữ liệu phát sinh cần phía logic hỗ trợ thêm.)*
