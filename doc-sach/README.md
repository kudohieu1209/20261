# Đọc sách

Web app đọc sách cá nhân: nhập EPUB/TXT, đọc kiểu sách in (lật 2 trang / 1 trang), lưu tiến độ offline-first, dấu trang, ghi chú/highlight, tìm kiếm toàn văn không dấu, đọc to (TTS) giọng Việt, PWA cài đặt như app và tự động giữ Supabase không bị tạm dừng.

## Cài đặt lần đầu

### 1. Tạo Supabase (miễn phí)
1. Vào https://supabase.com, đăng nhập rồi bấm **New project**. Đặt tên tùy ý, chọn region **Singapore**, đặt mật khẩu database và lưu lại.
2. Mở **SQL Editor** → **New query**:
   - Nếu cài mới: dán toàn bộ `supabase/schema.sql` rồi bấm **Run**.
   - Nếu đã có database từ phiên bản trước: chạy migration `supabase/migrations/002_features.sql`.
3. Mở **Authentication → Users → Add user → Create new user**, nhập email và mật khẩu bạn sẽ dùng để đăng nhập, tick **Auto Confirm User**.
4. Mở **Authentication → Sign In / Providers**, tắt **Allow new users to sign up** để không ai khác tạo được tài khoản.
5. Mở **Project Settings → API Keys**, copy **Project URL** và **Publishable key** (anon key).

### 2. Cấu hình app
```bash
cp .env.example .env.local   # rồi dán URL + key vào
npm install
npm run dev                  # mở http://localhost:5173
```

### 3. Deploy lên Vercel
1. Kết nối repository GitHub này trên https://vercel.com.
2. Đặt **Root Directory** là `doc-sach`.
3. Thêm các biến môi trường trong **Environment Variables**:
   - `VITE_SUPABASE_URL`: Project URL từ Supabase.
   - `VITE_SUPABASE_ANON_KEY`: Publishable key (anon) từ Supabase.
4. Bấm **Deploy**. App đã cấu hình `vercel.json` định tuyến SPA `/index.html` và PWA Service Worker để đọc offline.

### 4. Giữ Supabase không ngủ (GitHub Action Keepalive)
Gói Supabase Free tự động tạm dừng (pause) sau 7 ngày không có truy vấn. Repo đã có sẵn workflow `.github/workflows/supabase-keepalive.yml` tự động gọi hàm RPC `keepalive()` mỗi 3 ngày:
1. Vào repository GitHub của bạn → **Settings** → **Secrets and variables** → **Actions**.
2. Thêm 2 Repository Secrets:
   - `SUPABASE_URL`: URL dự án Supabase (ví dụ: `https://xyzcompany.supabase.co`).
   - `SUPABASE_PUBLISHABLE_KEY`: Anon / Publishable key của Supabase.
3. Có thể bấm **Run workflow** trong tab **Actions** → **Keep Supabase Alive** để kiểm tra ping ngay lập tức.

## Lệnh

| Lệnh | Việc |
|---|---|
| `npm run dev` | Chạy thử |
| `npm run build` | Type-check + build (kèm sinh PWA Service Worker & manifest) |
| `npm test` | Unit test (vitest) |
| `npm run lint` | Linter nhanh (oxlint) |
| `npm run sample` | Sinh truyện giả 1300 chương ở `samples/` để test |
| `EPUB_SAMPLE=đường/dẫn.epub npm test` | Chạy thêm test đọc một file EPUB thật |

## Cấu trúc

```
src/lib/        logic: tách chương (parseTxt, parseEpub), Supabase, cache IndexedDB, tiến độ, dấu trang, ghi chú, TTS, outbox sync
src/hooks/      useLibrary, useReader, usePaginator, usePageTurnControls, useAnnotations, useBookSearch, useTts, useInstallPrompt
src/workers/    search.worker.ts (tìm kiếm toàn văn không dấu chạy trên Web Worker)
src/pages/      giao diện (xem docs/UI_BRIEF.md)
src/styles/     tokens.css: màu, font, bo góc, spring animation tokens phong cách Apple
supabase/       schema.sql, migrations/002_features.sql
docs/           UI_BRIEF.md (brief cho agent giao diện), ref/ (ảnh tham khảo), PLAN.md
```
