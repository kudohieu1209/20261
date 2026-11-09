-- Chạy toàn bộ file này một lần trong Supabase Dashboard → SQL Editor.
-- Mọi bảng đều bật Row Level Security: mỗi tài khoản chỉ thấy dữ liệu của chính mình.

create extension if not exists pgcrypto;

-- ── Hàm cập nhật updated_at ────────────────────────────────────────────────
create or replace function public.touch_updated_at()
returns trigger language plpgsql as $$
begin
  new.updated_at := now();
  return new;
end $$;

-- ── Sách ───────────────────────────────────────────────────────────────────
-- Mục lục không lưu ở đây: nó được tách lại từ file gốc (parser_version
-- cho biết file được tách bằng phiên bản bộ tách nào).
create table public.books (
  id             uuid primary key default gen_random_uuid(),
  user_id        uuid not null default auth.uid() references auth.users on delete cascade,
  title          text not null,
  author         text,
  file_path      text not null,                         -- đường dẫn trong bucket "books"
  file_format    text not null check (file_format in ('txt', 'epub')),
  cover_path     text,                                  -- ảnh bìa trong bucket "books"
  parser_version int  not null default 1,
  status         text not null default 'to_read' check (status in ('to_read', 'reading', 'finished')),
  chapter_count  int  not null default 0,
  total_chars    bigint not null default 0,
  started_at     timestamptz,
  finished_at    timestamptz,
  rating         smallint check (rating between 1 and 5),
  review         text,
  created_at     timestamptz not null default now(),
  updated_at     timestamptz not null default now()
);
create index books_user_idx on public.books (user_id, updated_at desc);
create trigger books_touch before update on public.books
  for each row execute function public.touch_updated_at();

-- ── Tiến độ đọc (1 dòng / sách) ────────────────────────────────────────────
create table public.progress (
  book_id       uuid primary key references public.books on delete cascade,
  user_id       uuid not null default auth.uid() references auth.users on delete cascade,
  chapter_index int  not null default 0,
  char_offset   int  not null default 0,
  percent       real not null default 0 check (percent between 0 and 1),
  updated_at    timestamptz not null default now()
);

-- ── Dấu trang ──────────────────────────────────────────────────────────────
create table public.bookmarks (
  id            uuid primary key default gen_random_uuid(),
  user_id       uuid not null default auth.uid() references auth.users on delete cascade,
  book_id       uuid not null references public.books on delete cascade,
  chapter_index int  not null,
  char_offset   int  not null,
  label         text,
  created_at    timestamptz not null default now(),
  updated_at    timestamptz not null default now()
);
create index bookmarks_book_idx on public.bookmarks (book_id, chapter_index, char_offset);
create index bookmarks_user_updated_idx on public.bookmarks (user_id, updated_at desc);
create trigger bookmarks_touch before update on public.bookmarks
  for each row execute function public.touch_updated_at();

-- ── Ghi chú / highlight ────────────────────────────────────────────────────
create table public.notes (
  id            uuid primary key default gen_random_uuid(),
  user_id       uuid not null default auth.uid() references auth.users on delete cascade,
  book_id       uuid not null references public.books on delete cascade,
  chapter_index int  not null,
  char_start    int  not null,
  char_end      int  not null check (char_end >= char_start),
  quote         text not null,          -- đoạn được trích, để đọc lại khỏi cần mở sách
  content       text,                   -- lời ghi chú (null = chỉ highlight)
  color         text not null default 'yellow',
  created_at    timestamptz not null default now(),
  updated_at    timestamptz not null default now()
);
create index notes_book_idx on public.notes (book_id, chapter_index, char_start);
create index notes_user_updated_idx on public.notes (user_id, updated_at desc);
create trigger notes_touch before update on public.notes
  for each row execute function public.touch_updated_at();

-- ── Hàm giữ Supabase không ngủ (Keepalive) ─────────────────────────────────
create or replace function public.keepalive()
returns timestamptz
language sql
security definer
as $$
  select now();
$$;

grant execute on function public.keepalive() to anon, authenticated;

-- ── Nhật ký đọc (thống kê theo ngày) ───────────────────────────────────────
create table public.reading_logs (
  user_id    uuid not null default auth.uid() references auth.users on delete cascade,
  book_id    uuid not null references public.books on delete cascade,
  day        date not null default current_date,
  seconds    int  not null default 0,
  chars_read int  not null default 0,
  primary key (user_id, book_id, day)
);

-- ── Row Level Security ─────────────────────────────────────────────────────
do $$
declare t text;
begin
  foreach t in array array['books', 'progress', 'bookmarks', 'notes', 'reading_logs'] loop
    execute format('alter table public.%I enable row level security', t);
    execute format(
      'create policy "own rows" on public.%I for all to authenticated
         using (user_id = auth.uid()) with check (user_id = auth.uid())', t);
  end loop;
end $$;

-- ── Storage: bucket riêng tư chứa file sách, mỗi user một thư mục <user_id>/ ─
insert into storage.buckets (id, name, public)
values ('books', 'books', false)
on conflict (id) do nothing;

create policy "own book files" on storage.objects for all to authenticated
  using (bucket_id = 'books' and (storage.foldername(name))[1] = auth.uid()::text)
  with check (bucket_id = 'books' and (storage.foldername(name))[1] = auth.uid()::text);
