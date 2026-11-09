> **Ghi chú (2026-11-09):** Kế hoạch này do phiên Claude `planner-61` viết, nhưng người dùng đã **giao cho agy (Antigravity) thực hiện toàn bộ**. Với đợt này, agy được phép sửa cả vùng logic (`src/lib`, `src/hooks`, `src/workers`, `supabase/`, cấu hình) ngoài vùng giao diện. Chỗ nào trong văn bản ghi "mình làm" thì hiểu là agy làm. Thêm yêu cầu mới của người dùng: **nâng cấp animation theo phong cách Apple** (xem mục cuối).

# Kế hoạch: thêm 6 tính năng cho `doc-sach`

## Bối cảnh

App đã có các phần sau (commit `506c818`): đăng nhập Supabase, nhập EPUB/TXT, thư viện, đọc cuộn dọc, lưu tiến độ offline-first. Bạn chọn thêm 6 tính năng:

1. **Lật trang 2 trang** như sách in (giao diện trong ảnh tham khảo)
2. **Dấu trang + ghi chú/highlight**
3. **Tìm trong nội dung** cả 2.466 chương, gõ không dấu vẫn ra
4. **Đọc to (TTS)** bằng giọng Việt
5. **Cài như app (PWA)**, đọc được offline
6. **Giữ Supabase không ngủ** (project Free bị dừng sau 7 ngày không dùng)

**Phân công giữ như cũ:** mình làm logic (`src/lib`, `src/hooks`, `supabase/`, cấu hình). Trang trong `src/pages` chỉ nối dây ở mức tối thiểu để thử được. Phần giao diện đẹp thì cập nhật vào `docs/UI_BRIEF.md` cho agy. Agy chưa bắt đầu sửa gì, nên **mình làm xong đợt này rồi mới giao cho agy** để tránh hai bên sửa chồng lên nhau.

---

## Bước 0 — Nền tảng chung (các tính năng sau đều dựa vào)

**0.1 Chuẩn hoá Unicode NFC khi tách chương.**
`clean()` trong [parseEpub.ts](src/lib/parseEpub.ts) và phần đẩy đoạn văn trong [parseTxt.ts](src/lib/parseTxt.ts) thêm `.normalize('NFC')`, và tăng `PARSER_VERSION` lên 2.
Lý do: văn bản tiếng Việt trên web hay dùng dấu "tổ hợp" (chữ và dấu tách rời). Chuẩn hoá về NFC thì vị trí ký tự của ghi chú, kết quả tìm kiếm và câu TTS mới khớp nhau.

**0.2 `foldViSameLength()` trong [text.ts](src/lib/text.ts).**
Bỏ dấu nhưng **giữ nguyên độ dài chuỗi** (mỗi ký tự thành đúng 1 ký tự; dùng bảng tra cache cho ký tự > 127). Nhờ vậy vị trí tìm thấy trong chuỗi đã bỏ dấu cũng chính là vị trí trong văn bản gốc. `foldVi`/`matchesVi` hiện có giữ nguyên.

**0.3 Hàng đợi đồng bộ chung (outbox) — file mới `src/lib/sync.ts`.**
- Bảng Dexie `outbox` gồm `{ id, table, op: 'upsert'|'delete', rowId, payload }`. Thao tác lặp lại trên cùng một `(table,rowId)` được gộp, chỉ giữ thao tác mới nhất.
- `flushOutbox()` đẩy lần lượt lên Supabase, lỗi thì để lại chờ lần sau. Hàm `startSync()` thay cho `startProgressSync()`, vẫn kích hoạt khi có mạng lại hoặc khi rời tab.
- Chuyển [progress.ts](src/lib/progress.ts) sang dùng outbox; API `saveProgress`/`getProgress` giữ nguyên.
- `pullBookAnnotations(bookId)`: tải dấu trang và ghi chú từ server rồi ghép vào máy. Bản ghi đã đồng bộ mà server không còn thì xoá ở máy, nhờ vậy xoá trên máy này thì máy kia cũng mất, không cần cột tombstone.

**0.4 Dexie lên `version(2)`** trong [localDb.ts](src/lib/localDb.ts): thêm `bookmarks`, `notes`, `outbox`, `pageCounts`.

**0.5 Migration SQL — file mới `supabase/migrations/002_features.sql`.**
Viết theo kiểu chạy lại nhiều lần vẫn an toàn (`if not exists`):
- `bookmarks.updated_at`
- hàm `public.keepalive()` trả về `now()`, cấp quyền `execute` cho `anon` (dùng ở bước 6)
- index phụ nếu cần

Gộp luôn vào `schema.sql` để ai cài mới chỉ chạy một file.

**0.6 Thêm thư viện:** `dexie-react-hooks` (`useLiveQuery` giúp danh sách dấu trang/ghi chú tự cập nhật) và `vite-plugin-pwa`.

---

## Bước 1 — Lật trang 2 trang (`src/hooks/usePaginator.ts`)

**Cách chia trang:** chương hiện tại được render trong một khung cao cố định và dùng CSS multi-column: `column-width` bằng bề rộng một trang, `column-fill: auto`. Lật trang là dịch `translateX` một khoảng bằng bề rộng phần đang hiển thị.
- **Hai trang** khi khung rộng ≥ 900px và màn ngang; còn lại một trang.
- Số trang trong chương = `scrollWidth / (pageWidth + gap)`.

**Xác định vị trí chính xác tới từng ký tự:**
- *Đang ở đâu:* dùng `caretPositionFromPoint`/`caretRangeFromPoint` tại góc trên trái của trang đầu đang hiện → ra nút văn bản + vị trí trong nút → cộng với `data-offset` của đoạn → `charOffset`. Kết quả gửi `reportPosition()` (đã có trong [useReader.ts](src/hooks/useReader.ts)).
- *Khôi phục:* tạo `Range` tại `restoreOffset`, lấy `getBoundingClientRect()` rồi suy ra trang chứa nó.
- Sau khi đổi cỡ chữ, xoay màn hoặc thay đổi kích thước (`ResizeObserver`, chờ `document.fonts.ready`), app đo lại và **giữ đúng chữ đang đọc**, không nhảy về đầu chương.

**Sang chương:**
- Đang ở trang cuối mà lật tiếp → `nextChapter()`, mở chương mới ở trang 1.
- Đang ở trang đầu mà lùi → `prevChapter()`, mở ở trang cuối. Để làm được việc này, `goToChapter` nhận thêm `offset = 'end'` (sửa nhỏ trong `useReader`).

**Điều khiển** — hook `usePageTurnControls`:
- Phím ←/→/Space/PageUp/PageDown
- Vuốt ngang bằng pointer events (ngưỡng khoảng 40px)
- Chạm theo vùng: 30% trái lùi trang, 30% phải sang trang, phần giữa bật/tắt thanh công cụ
- Bỏ qua thao tác chạm khi đang bôi đen chữ, để không xung đột với ghi chú

**Số trang toàn sách `[8551]`** — file `src/lib/pageCounts.ts`:
- Chạy nền lúc rảnh (`requestIdleCallback`): render từng chương vào một khung ẩn có cùng CSS và đếm số trang.
- Cache trong Dexie `pageCounts` theo khoá `hash(cỡ chữ, giãn dòng, font, w×h trang)`.
- Khi chưa đếm xong thì hiện `percent`.

**Dữ liệu `usePaginator` trả ra:**
`{ page, pageCount, spread, pageRange: {start,end}, globalPage?, totalPages?, next(), prev(), goToOffset(offset), remeasure() }`.

[ReaderPage.tsx](src/pages/ReaderPage.tsx) chuyển từ cuộn dọc sang lật trang, giao diện vẫn ở mức tối thiểu.

---

## Bước 2 — Dấu trang + ghi chú (`src/lib/annotations.ts`, `src/hooks/useAnnotations.ts`)

**Hàm thao tác dữ liệu:**
- `addBookmark` / `removeBookmark`
- `addNote({chapterIndex, start, end, quote, color, content})` / `updateNote` / `removeNote`

Mỗi hàm ghi vào Dexie trước rồi xếp vào outbox để đồng bộ. Màu ghi chú có 4 mức xám/vàng nhạt; agy chốt màu cụ thể trong token.

**`useAnnotations(bookId)`** dùng `useLiveQuery` và trả về:
- `bookmarks`, `notes` (sắp theo vị trí)
- `isBookmarked(pageRange)` và `toggleBookmark(pageRange)` — trang được coi là có dấu nếu có dấu trang nằm trong khoảng ký tự của trang
- `notesForChapter(i)`

Khi mở sách, hook gọi `pullBookAnnotations`.

**Hàm hỗ trợ cho phần giao diện:**
- `selectionToRange(root)`: biến vùng bôi đen trong trình duyệt thành `{chapterIndex, start, end, quote}`. Cách tính: tạo Range từ đầu đoạn `[data-offset]` tới điểm bôi đen rồi lấy `toString().length`, nên vẫn đúng khi đoạn đã bị chia nhỏ bởi các thẻ `<mark>`.
- `segmentParagraph(p, highlights)`: tách một đoạn thành `[{text, noteId?, color?, ttsActive?}]` để vẽ highlight. Hàm này dùng chung cho ghi chú, kết quả tìm kiếm và câu TTS đang đọc. Ghi chú kéo qua nhiều đoạn được cắt theo từng đoạn.

**Nối dây tạm trong `ReaderPage`:** khi bôi đen hiện nút "Highlight / Ghi chú"; có nút dấu trang; tab Dấu trang và Ghi chú trong mục lục liệt kê các mục, bấm vào thì nhảy tới (`goToChapter(i, offset)` → `goToOffset`).

---

## Bước 3 — Tìm trong nội dung (Web Worker)

**Vì sao không dùng thư viện chỉ mục như MiniSearch:** 25 triệu ký tự sẽ tạo chỉ mục khoảng 100–200 MB RAM, quá nặng cho tablet. Thay vào đó **quét tuần tự** trên văn bản đã bỏ dấu (giữ nguyên độ dài, xem 0.2). Phép `indexOf` trên 25 triệu ký tự mất cỡ vài chục ms, lại tìm được chính xác cả cụm từ.

**`src/workers/search.worker.ts`:**
- Dexie chạy được trong worker. Lần tìm đầu tiên, worker đọc toàn bộ `texts` của sách, bỏ dấu một lần rồi giữ trong bộ nhớ, khoảng 50 MB và chỉ tồn tại khi đang mở sách.
- Nhận `{query, limit}` và trả về `[{chapterIndex, offset, length, snippet}]`. `snippet` gồm khoảng 40 ký tự trước và sau lấy từ văn bản gốc có dấu.
- Gửi kết quả theo từng đợt để danh sách hiện dần, và hủy được khi người dùng gõ tiếp.

**Phần lõi viết thành hàm thuần** `searchFolded(chapters, query, limit)` trong `src/lib/search.ts` để test được.

**`useBookSearch(bookId)`** trả về `{ query, setQuery (debounce 300ms), results, searching, total }`.
- Bấm một kết quả: `goToChapter(i, offset)` và tô sáng chỗ tìm thấy vài giây (qua `segmentParagraph`).
- Giao diện tạm: thêm tab "Tìm" trong modal mục lục.

---

## Bước 4 — Đọc to (`src/lib/tts.ts`, `src/hooks/useTts.ts`)

**Cách đọc:** dùng Web Speech API (`speechSynthesis`), chọn giọng `vi-*`. Chrome Android dùng giọng Google tiếng Việt có sẵn trong máy.
- **Đọc từng câu:** `splitSentences(paragraphs)` trả về `[{start, end}]`, cắt theo `. ! ? … ” "` và giới hạn tối đa khoảng 200 ký tự mỗi câu. Lý do: Chrome Android hay tự ngắt khi một lần đọc quá dài.
- **Tạm dừng:** làm bằng `cancel()` và nhớ lại câu đang đọc, vì `pause()/resume()` trên Android chạy không ổn định.

**`useTts(reader, paginator)`** trả về:
- `{ supported, voices, voice, setVoice, rate (0.8–2), setRate, playing, current: {start,end}, play(fromOffset?), pause(), stop() }`
- Bắt đầu đọc từ đầu trang đang xem.
- Câu đang đọc được tô sáng; câu đó ra khỏi trang thì tự lật (`goToOffset`).
- Hết chương thì tự `nextChapter()` và đọc tiếp.
- Giọng và tốc độ lưu trong `localStorage`.

**Giới hạn cần biết:** khi tắt màn hình hoặc chuyển sang app khác, Chrome có thể dừng đọc. Đây là giới hạn của trình duyệt, ghi rõ trong README.

---

## Bước 5 — Cài như app (PWA) + đưa lên mạng

**Cấu hình `vite-plugin-pwa`** trong [vite.config.ts](vite.config.ts):
- `registerType: 'autoUpdate'`
- **manifest:** tên "Đọc sách", `display: standalone`, `theme_color #ffffff`, hiển thị ngang lẫn dọc (`orientation: any`)
- **precache:** khung app (JS, CSS, HTML) và font Libertinus/Inter
- `navigateFallback: '/index.html'` để các đường dẫn như `/read/:id` mở được khi offline
- request tới Supabase để `NetworkOnly`, vì dữ liệu offline đã nằm trong Dexie, service worker không cache dữ liệu

**Icon:** tạo `public/logo.svg` (hình sách tối giản, đen trên trắng), rồi sinh PNG 192/512/maskable bằng `@vite-pwa/assets-generator`. Nếu `sharp` không chạy trong proot thì dùng `jimp`.

**`navigator.storage.persist()`** khi nhập sách đầu tiên, để Chrome không tự xoá IndexedDB (có thể vài trăm MB sách).

**Nút "Cài app"** dùng sự kiện `beforeinstallprompt`, gói trong hook `useInstallPrompt`.

**Hosting:** PWA cần HTTPS nên phải đưa lên mạng. Mình chọn **Vercel** (miễn phí, tự build mỗi lần push):
- `vercel.json` có `rewrites` cho SPA
- Bạn cần tự làm trên giao diện Vercel: import repo `20261`, chọn **Root Directory = `doc-sach`**, thêm 2 biến môi trường `VITE_SUPABASE_*`
- Thêm domain Vercel vào **Supabase → Auth → URL Configuration**

---

## Bước 6 — Giữ Supabase không ngủ

**`.github/workflows/supabase-keepalive.yml`** ở **gốc repo `20261`**, vì GitHub chỉ đọc workflow ở gốc repo:
- Chạy theo lịch `0 3 */3 * *` (3 ngày một lần) và có `workflow_dispatch` để bấm chạy tay.
- Gửi `curl -X POST $SUPABASE_URL/rest/v1/rpc/keepalive` kèm header `apikey`.
- Báo lỗi (fail job) nếu status khác 200, để GitHub gửi mail cho bạn.

**Bạn cần tự thêm** 2 secret `SUPABASE_URL`, `SUPABASE_PUBLISHABLE_KEY` vào repo trên GitHub. Lưu ý: GitHub tự tắt workflow theo lịch nếu repo 60 ngày không có commit; bạn commit thường xuyên nên không lo.

---

## Bước 7 — Cập nhật brief cho agy

- **[docs/UI_BRIEF.md](docs/UI_BRIEF.md)** thêm các mục:
  - trang đọc dạng lật trang (thay đoạn "tạm giữ cuộn dọc")
  - thanh chọn chữ: Highlight, Ghi chú, Sao chép
  - nút dấu trang (ruy băng góc trang)
  - tab Dấu trang / Ghi chú / Tìm trong mục lục
  - thanh điều khiển TTS: phát/dừng, tốc độ, giọng; tô câu đang đọc
  - nút Cài app
  - token màu highlight (vẫn trong tông xám/vàng rất nhạt)
- **Mục 3 của brief** liệt kê API của các hook mới: `usePaginator`, `usePageTurnControls`, `useAnnotations`, `useBookSearch`, `useTts`, `useInstallPrompt`, và helper `segmentParagraph`/`selectionToRange`.
- **[AGENTS.md](AGENTS.md)** thêm `src/workers/` vào vùng logic.
- **README** thêm phần chạy migration 002, triển khai Vercel và cài secret cho GitHub Actions.

---

## Thứ tự làm và commit

Mỗi bước một commit trong repo `20261`, kiểu `feat(doc-sach): …`, push sau mỗi bước khi build và test đã qua:
0 → 1 → 2 → 3 → 4 → 5 → 6 → 7

## Kiểm tra

**Unit test** (vitest, thêm vào bộ test sẵn có):
- `foldViSameLength`: giữ nguyên độ dài, kể cả với chuỗi dấu tổ hợp sau khi chuẩn hoá NFC
- outbox: gộp thao tác, xử lý lỗi rồi thử lại (dùng `fake-indexeddb` đã cài)
- `segmentParagraph`: các khoảng chồng nhau, cắt qua nhiều đoạn
- `selectionToRange` (happy-dom)
- `searchFolded`: có dấu/không dấu, giới hạn số kết quả, snippet
- `splitSentences`
- parser trả về văn bản NFC
- Chạy lại `EPUB_SAMPLE=… npm test` với file Phàm Nhân Tu Tiên: tìm "han lap" phải ra kết quả, thời gian quét dưới 1 giây

**Build:** `npm run build` và `npm run lint` không có lỗi mới. Build xong phải có `dist/sw.js` và `manifest.webmanifest`.

**Thử thật trên tablet** (Chrome, `npm run dev` hoặc bản Vercel), cần Supabase đã cấu hình:
1. Nhập EPUB Phàm Nhân, mở sách: màn ngang hiện 2 trang, màn dọc hiện 1 trang. Lật bằng vuốt, phím và chạm.
2. Đổi cỡ chữ, xoay màn: vẫn ở đúng câu đang đọc. Thoát ra mở lại: đúng trang.
3. Lật qua cuối chương: sang chương sau. Lùi ở trang đầu: về trang cuối chương trước.
4. Bôi đen tạo highlight và ghi chú, thêm dấu trang. Tải lại trang vẫn còn. Mở trên máy thứ hai: dữ liệu đã đồng bộ. Xoá trên máy này thì máy kia cũng mất.
5. Tìm "co dia hu thien dien": ra Chương 1125, bấm vào nhảy đúng đoạn và có tô sáng.
6. Bấm đọc to: nghe giọng Việt, câu đang đọc được tô sáng, tự lật trang và tự sang chương.
7. Bản Vercel: cài lên màn hình chính, bật chế độ máy bay, mở app vẫn vào thư viện và đọc được sách đã tải.
8. GitHub Actions: bấm chạy tay workflow keepalive, job xanh.

## Những gì bạn phải tự làm (mình sẽ hướng dẫn từng bước)

- Chạy `supabase/migrations/002_features.sql` trong Supabase SQL Editor
- Tạo project Vercel (Root Directory `doc-sach`, 2 biến môi trường), thêm domain vào Supabase Auth
- Thêm 2 secret vào repo GitHub `20261`
- Cài giọng tiếng Việt trong Cài đặt Android → Chuyển văn bản thành giọng nói (nếu máy chưa có)

---

## Bổ sung: animation phong cách Apple (yêu cầu thêm của người dùng)

- Chuyển động mềm, dùng spring/ease-out (ví dụ `cubic-bezier(0.32, 0.72, 0, 1)`), thời lượng 200–450 ms; không nảy lố.
- Áp dụng cho: lật trang (Bước 1), mở/đóng sách từ thư viện, sheet/panel trượt lên (ghi chú, tìm kiếm, cài đặt), nút bấm có phản hồi nhấn nhẹ (scale ~0,97).
- Chỉ animate `transform` và `opacity` để mượt trên tablet; tôn trọng `prefers-reduced-motion`.
- Token thời lượng/easing thêm vào `src/styles/tokens.css`, không viết số rời rạc trong component.
