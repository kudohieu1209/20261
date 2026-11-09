-- Migration 002: Thêm updated_at cho bookmarks, hàm keepalive và index phụ
-- Chạy lại nhiều lần vẫn an toàn (idempotent).

-- 1. Cột updated_at và trigger cho bảng bookmarks
alter table public.bookmarks
  add column if not exists updated_at timestamptz not null default now();

drop trigger if exists bookmarks_touch on public.bookmarks;
create trigger bookmarks_touch
  before update on public.bookmarks
  for each row execute function public.touch_updated_at();

-- 2. Hàm keepalive để GitHub Actions ping giữ Supabase không bị tạm dừng (ngủ)
create or replace function public.keepalive()
returns timestamptz
language sql
security definer
as $$
  select now();
$$;

-- Cấp quyền gọi keepalive cho cả anon và authenticated
grant execute on function public.keepalive() to anon, authenticated;

-- 3. Index phụ hỗ trợ sắp xếp và truy vấn nhanh
create index if not exists bookmarks_user_updated_idx
  on public.bookmarks (user_id, updated_at desc);

create index if not exists notes_user_updated_idx
  on public.notes (user_id, updated_at desc);
