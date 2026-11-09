# Đọc sách

Web app đọc sách cá nhân: nhập EPUB/TXT, đọc kiểu sách in, lưu tiến độ, ghi chú, đồng bộ qua Supabase.

## Cài đặt lần đầu

### 1. Tạo Supabase (miễn phí)
1. Vào https://supabase.com, đăng nhập rồi bấm **New project**. Đặt tên tùy ý, chọn region **Singapore**, đặt mật khẩu database và lưu lại.
2. Mở **SQL Editor** → **New query**, dán toàn bộ `supabase/schema.sql` rồi bấm **Run**.
3. Mở **Authentication → Users → Add user → Create new user**, nhập email và mật khẩu bạn sẽ dùng để đăng nhập, tick **Auto Confirm User**.
4. Mở **Authentication → Sign In / Providers**, tắt **Allow new users to sign up** để không ai khác tạo được tài khoản.
5. Mở **Project Settings → API Keys**, copy **Project URL** và **Publishable key**.

### 2. Cấu hình app
```bash
cp .env.example .env.local   # rồi dán URL + key vào
npm install
npm run dev                  # mở http://localhost:5173
```

## Lệnh

| Lệnh | Việc |
|---|---|
| `npm run dev` | Chạy thử |
| `npm run build` | Type-check + build |
| `npm test` | Unit test |
| `npm run sample` | Sinh truyện giả 1300 chương ở `samples/` để test |
| `EPUB_SAMPLE=đường/dẫn.epub npm test` | Chạy thêm test đọc một file EPUB thật |

## Cấu trúc

```
src/lib/        logic: tách chương (parseTxt, parseEpub), Supabase, cache IndexedDB, tiến độ
src/hooks/      useLibrary, useReader: dữ liệu cho từng màn hình
src/pages/      giao diện (đang là bản tạm, xem docs/UI_BRIEF.md)
src/styles/     tokens.css: màu, font, bo góc
supabase/       schema.sql
docs/           UI_BRIEF.md (brief cho agent giao diện), ref/ (ảnh tham khảo)
```
