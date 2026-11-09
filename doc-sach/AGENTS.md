# Hướng dẫn cho AI agent

App đọc sách cá nhân: React 19 + TypeScript + Vite, Supabase (auth + Postgres + Storage), Dexie (IndexedDB cache).

## Phân vùng

| Thư mục | Ai sửa | Ghi chú |
|---|---|---|
| `src/lib/`, `src/hooks/`, `supabase/` | Phần logic | Agent giao diện **không sửa**, ghi yêu cầu vào mục 5 của `docs/UI_BRIEF.md` |
| `src/pages/`, `src/components/`, `src/styles/` | Agent giao diện | Làm theo **`docs/UI_BRIEF.md`** |

## Lệnh

```bash
npm run dev      # chạy thử (cần .env.local, xem README)
npm run build    # type-check + build
npm test         # unit test (vitest)
npm run lint     # oxlint
```

## Quy tắc chung
- Giao diện tiếng Việt. Comment code tiếng Việt.
- Màu, font, bo góc, bóng chỉ lấy từ `src/styles/tokens.css`.
- Mỗi đoạn văn trong trang đọc phải giữ `data-offset`, vì logic lưu vị trí đọc dựa vào nó.
