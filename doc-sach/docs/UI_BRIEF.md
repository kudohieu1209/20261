# Brief giao diện — app Đọc sách

> Dành cho agent làm giao diện (Antigravity). Đọc hết file này trước khi sửa code.

## 0. Bối cảnh và phân công

- App đọc sách cá nhân (một người dùng), chạy trên **tablet Android, màn hình ngang** là chính. Điện thoại dọc vẫn phải dùng được.
- Sách thường rất dài: 1.500–2.500 chương, 20–25 triệu ký tự (truyện tiên hiệp dịch).
- **Toàn bộ logic đã xong**: đăng nhập (Supabase), nhập EPUB/TXT, tách chương, cache offline, lưu tiến độ. Phần đó nằm trong `src/lib/` và `src/hooks/`.
- **Việc của bạn là phần trình bày**: thiết kế lại 3 trang trong `src/pages/` và tạo các component trong `src/components/`.

### Được làm
- Viết lại JSX và CSS của `src/pages/*.tsx`; tạo `src/components/**`, `src/styles/**`.
- Dùng **CSS Modules** (`*.module.css`) và các biến trong `src/styles/tokens.css`.
- Cài `lucide-react` để lấy icon (nét 1.5px, cỡ 20px).
- Thêm biến mới vào `tokens.css` nếu thật sự cần, ghi chú lý do ngay cạnh biến.

### Không được làm
- **Không sửa `src/lib/**` và `src/hooks/**`.** Cần thêm dữ liệu hay hàm thì ghi vào cuối file này ở mục "Yêu cầu cho phần logic".
- Không cài Tailwind, UI kit (MUI, Chakra…), hay thư viện animation nặng.
- Không hard-code màu, bo góc, bóng hay font. Mọi giá trị lấy từ `var(--…)`.
- **Không dùng màu nhấn đỏ/xanh** như ảnh tham khảo. Giai đoạn này app chỉ dùng **đen–trắng–xám**. Màu duy nhất được phép là `--color-danger`, và chỉ cho nút Xóa.

## 1. Phong cách

**Apple: mềm mại, sạch, thoáng.** Hình dung Apple Books và Settings trên iPadOS.

| Yếu tố | Quy tắc |
|---|---|
| Theme | Chỉ **Light**. Nền `--color-bg` trắng, khối nổi dùng `--color-surface` (#f5f5f7) |
| Màu | Đen–trắng–xám. Nút chính nền `--color-accent` (đen), chữ trắng |
| Bo góc | Lớn và mềm: nút `--radius-md`, thẻ `--radius-lg`, modal `--radius-xl`, nút icon tròn `--radius-full` |
| Bóng | Nhẹ, lan rộng (`--shadow-sm/md/lg`). Không dùng viền đậm; cần tách lớp thì dùng `--color-border` (8% đen) |
| Thanh công cụ nổi | Kính mờ: `background: var(--glass-bg); backdrop-filter: var(--glass-blur)` |
| Khoảng trắng | Rộng rãi, theo thang `--space-*` (bội số 4) |
| Chuyển động | `var(--duration)` + `var(--ease)`; modal và sheet dùng `--ease-spring`. Tôn trọng `prefers-reduced-motion` (token đã tự về 0) |
| Chạm | Vùng bấm tối thiểu **44×44px**. Có trạng thái hover/pressed (`--color-hover`, `--color-pressed`) |
| Ngôn ngữ | Toàn bộ chữ trên giao diện bằng **tiếng Việt** |

### Font
- **Nội dung sách và tiêu đề trong sách**: `var(--font-book)` = **Libertinus Serif**, font mặc định của Typst, giống các báo cáo viết bằng Typst. Font đã được nạp sẵn, có đủ tiếng Việt.
- **Giao diện** (nút, menu, nhãn): `var(--font-ui)`, kiểu SF Pro / Inter.
- **Tên gốc chữ Hán**: `var(--font-cjk)`.
- Tên sách ở thư viện và tiêu đề lớn có thể dùng `--font-book` để có chất "sách in".

## 2. Các màn hình

### 2.1 Đăng nhập (`LoginPage`)
- Thẻ trắng ở giữa màn hình, `--radius-xl`, `--shadow-lg`, trên nền `--color-surface`.
- Tên app "Đọc sách" viết bằng `--font-book`, cỡ `--text-3xl`.
- Hai ô nhập (email, mật khẩu) nền `--color-surface`, không viền, `--radius-md`, cao 48px.
- Nút "Đăng nhập" đen, rộng hết thẻ. Lỗi hiện thành dòng chữ nhỏ dưới nút.
- Không có nút đăng ký, vì app chỉ có một tài khoản.

### 2.2 Thư viện (`LibraryPage`)
Dữ liệu lấy từ `useLibrary()`, xem mục 3.

- **Thanh trên** (dính đầu trang, kính mờ khi cuộn): tiêu đề lớn "Thư viện" (kiểu large title của iOS), bên phải có nút pill "＋ Thêm sách" và nút tròn tài khoản (mở menu nhỏ có "Đăng xuất").
- **Đang nhập sách**: nút "Thêm sách" đổi thành thanh tiến trình gọn, ghi bước hiện tại (`importing.stage`). Ở bước `parsing` có `done/total` thì hiện phần trăm. Một file EPUB 2.500 chương mất vài giây.
- **Ba nhóm**, mỗi nhóm có tiêu đề nhỏ và ẩn đi nếu rỗng:
  1. **Đang đọc**: thẻ lớn nằm ngang, gồm ảnh bìa, tên, tác giả, thanh tiến độ mảnh, "Chương X · 37%" và nút "Đọc tiếp".
  2. **Muốn đọc**: lưới bìa sách.
  3. **Đã đọc xong**: lưới bìa sách, dưới mỗi bìa ghi "Xong ngày dd/mm/yyyy".
- **Bìa sách**: tỉ lệ 2:3, `--radius-md`, `--shadow-md`. Lấy ảnh qua `getCoverUrl(book)` (trả về `blob:` URL, nhớ `URL.revokeObjectURL` khi unmount). **Sách không có bìa** thì tự vẽ bìa chữ: nền `--color-surface`, tên sách bằng `--font-book` ở giữa, tác giả nhỏ phía dưới, kèm một đường kẻ trang trí mảnh.
- Mỗi sách có nút "…" (hoặc nhấn giữ) mở menu: Đổi trạng thái (Muốn đọc / Đang đọc / Đã đọc xong) và Xóa (màu `--color-danger`, hỏi xác nhận bằng dialog tự làm, không dùng `confirm()`).
- **Trạng thái rỗng**: icon sách mảnh, dòng chữ "Chưa có sách nào" và nút "Thêm sách đầu tiên".
- Lưới tự co giãn: `grid-template-columns: repeat(auto-fill, minmax(140px, 1fr))`.

### 2.3 Màn hình đọc (`ReaderPage`) — quan trọng nhất
Dữ liệu lấy từ `useReader(bookId)`, xem mục 3. Bố cục mục tiêu nằm ở `docs/ref/reader-spread.jpg` (trang đọc 2 trang) và `docs/ref/toc-modal.jpg` (mục lục). Đây là ảnh chụp màn hình trình duyệt; **chỉ lấy phần sách ở giữa, bỏ qua giao diện Facebook xung quanh**. **Lấy bố cục, không lấy màu đỏ.**

**Khung trang**
- Màn ngang rộng ≥ 900px: **hai trang đối diện** như sách mở, có bóng gáy mờ ở giữa (`--color-page-gutter`).
- Màn hẹp hoặc dọc: một trang.
- Nền trang `--color-page`, chữ `--color-page-text`.
- **Header chạy** ở đầu mỗi trang, chữ nhỏ `--color-page-muted`, font sách: trang trái ghi tên sách, trang phải ghi "Chương 1125: Tên chương". Góc ngoài ghi tiến độ (tạm hiện `percent`, ví dụ "37,2%". Số trang `[8551]` sẽ có sau).

**Mở đầu chương** (khi đọc tới đầu chương)
- Nếu là chương đầu của một Quyển: hiện tên Quyển ("QUYỂN 7", chữ hoa giãn chữ `letter-spacing: 0.2em`, cỡ nhỏ) và tên Quyển lớn bên dưới.
- Nhãn chương "CHƯƠNG 1125" (chữ hoa, giãn chữ), rồi tên chương lớn, đậm vừa (600).
- Hoa văn ngăn cách: `——— ◆ ———`, đường kẻ mảnh, màu chữ chính.
- Tên gốc chữ Hán (`originalTitle`) nếu có, font CJK, cỡ nhỏ.
- **Drop cap**: chữ cái đầu đoạn đầu tiên cao khoảng 3 dòng (`::first-letter` với `initial-letter: 3` hoặc float).

**Chữ nội dung**
- `font-family: var(--font-book)`, `font-size: var(--book-font-size)`, `line-height: var(--book-line-height)`.
- Căn đều hai bên (`text-align: justify`), `hyphens: none` (tiếng Việt không ngắt từ).
- Thụt đầu dòng `--book-paragraph-indent`, trừ đoạn đầu chương. Không có khoảng cách giữa các đoạn.
- Lề trang rộng, khoảng 8–10% bề rộng trang.

**Điều khiển**
- Nút tròn kính mờ ‹ › ở hai mép giữa màn hình để sang trang hoặc chương. Phím ← → cũng làm được việc này.
- Chạm vào vùng giữa màn hình thì hiện/ẩn thanh công cụ: trên là nút "‹ Thư viện", tên sách và nút Mục lục; dưới là thanh tiến độ toàn sách.
- Góc dưới trái có cụm nút tròn nhỏ dọc: **Aa** (cài đặt chữ). Chỗ cho nút đọc to (TTS) để sau, không cần làm.
- **Popover "Aa"**: chỉnh cỡ chữ (A− / A+, 15–28px), giãn dòng (3 mức), lưu vào `localStorage` và gán lên `--book-font-size` / `--book-line-height`.

**Chia trang**: tạm thời giữ **chế độ cuộn dọc** như code hiện tại, vì việc báo vị trí qua `reportPosition` và khôi phục bằng `restoreOffset` đang chạy được. Bộ chia trang hai trang (`usePaginator`) sẽ do phần logic làm sau. Hãy dựng sẵn khung trang, header chạy, mở đầu chương và kiểu chữ sao cho khi có bộ chia trang chỉ cần cắm vào.
- Mỗi đoạn văn **bắt buộc** giữ thuộc tính `data-offset={p.start}`, vì logic lưu vị trí dựa vào nó.

### 2.4 Mục lục (sheet/modal mở từ màn hình đọc)
Theo ảnh tham khảo thứ hai:
- Modal giữa màn hình, rộng khoảng 560px, cao khoảng 80vh, `--radius-xl`, `--shadow-lg`, nền mờ `--color-scrim`. Trên điện thoại thì thành bottom sheet.
- Đầu modal: tên sách, nút ✕ tròn.
- **Segmented control** 3 tab: "Mục lục" / "Dấu trang 0" / "Ghi chú 0". Hai tab sau tạm hiện trạng thái rỗng "Sắp có".
- **Ô tìm**: "Tìm trong {n} chương…", lọc theo `label` + `title`, **không phân biệt dấu**, dùng `matchesVi` trong `src/lib/text.ts`.
- **Danh sách theo Quyển**, gập/mở được: dòng Quyển gồm "Quyển 7" đậm, số chương (pill xám nhỏ), tên Quyển nhỏ phía dưới và % vị trí ở bên phải (`chapters[đầu quyển].charStart / book.total_chars`). Quyển chứa chương đang đọc mở sẵn và tự cuộn tới chương đó. Chương đang đọc được tô nền `--color-surface` và in đậm.
- **Sách không chia Quyển** (`toc.volumes` rỗng): tự gom thành nhóm 100 chương ("Chương 1–100", "Chương 101–200"…) để danh sách không quá dài.
- **Hiệu năng**: sách có tới khoảng 2.500 chương. Chỉ render chương của các nhóm đang mở; khi đang tìm thì giới hạn 200 kết quả đầu.

## 3. Dữ liệu có sẵn (chỉ dùng, không sửa)

```ts
// src/hooks/useLibrary.ts
const {
  items,        // { book: Book; progress: Progress | null }[]
  loading, error,
  importing,    // null | { stage: 'reading'|'parsing'|'uploading'|'saving'; done?: number; total?: number }
  importFile,   // (file: File) => Promise<Book | null>    — nhận .epub và .txt
  changeStatus, // (book, 'to_read'|'reading'|'finished') => Promise<void>
  remove,       // (book) => Promise<void>
  refresh,
} = useLibrary()

// src/lib/books.ts
getCoverUrl(book): Promise<string | null>   // blob: URL hoặc null

// src/hooks/useReader.ts
const {
  book,          // Book: title, author, status, total_chars, chapter_count...
  toc,           // { volumes: {index,label,title,originalTitle}[]; chapters: ChapterMeta[] }
  chapter,       // ChapterMeta: index, volumeIndex, label, title, originalTitle, charStart, charLength
  paragraphs,    // { start: number; text: string }[]  — đoạn văn của chương hiện tại
  restoreOffset, // number | null — vị trí cần cuộn tới khi vừa mở chương
  percent,       // 0..1 toàn sách
  loading, error,
  isLastChapter,
  goToChapter,   // (index, offset?) => void
  nextChapter, prevChapter,
  reportPosition,// (charOffset) => void — gọi khi người đọc dừng ở vị trí mới
  markFinished,  // () => void — gọi khi đọc tới cuối chương cuối
} = useReader(bookId)

// src/lib/auth.tsx
useAuth() → { session, loading };  signIn(email, password);  signOut()

// src/lib/text.ts
matchesVi(haystack, query): boolean   // tìm không dấu
```

## 4. Kiểm tra trước khi bàn giao

- [ ] `npm run build` không lỗi, `npm run lint` không có lỗi mới.
- [ ] Không còn màu, bo góc hay font hard-code (tìm thử `#`, `px` trong `*.module.css`; chỉ được có px cho kích thước bố cục).
- [ ] Màn tablet ngang (khoảng 1200×750 CSS px) và điện thoại dọc (390×844) đều đẹp, không cuộn ngang.
- [ ] Mở sách 2.466 chương: mục lục mở mượt, tìm "co dia" ra chương "Cố địa…".
- [ ] Đọc, thoát ra rồi mở lại sách thì về đúng đoạn đang đọc.
- [ ] Mọi nút bấm ≥ 44px, có trạng thái nhấn.

## 5. Yêu cầu cho phần logic

_(Agent giao diện ghi vào đây những gì cần thêm ở `src/lib` / `src/hooks`.)_
