-- =====================================================================
-- SỔ THU CHI – Supabase schema
-- Cách chạy: Supabase Dashboard → SQL Editor → New query → dán toàn bộ → Run
-- Có thể chạy lại nhiều lần (idempotent), trừ phần CREATE TYPE đã được bọc kiểm tra.
-- =====================================================================

-- 1. KIỂU DỮ LIỆU ------------------------------------------------------
do $$ begin
  create type public.tx_type   as enum ('thu', 'chi');
exception when duplicate_object then null; end $$;

do $$ begin
  create type public.tx_status as enum ('done', 'pending');
exception when duplicate_object then null; end $$;

-- 2. BẢNG DANH MỤC -----------------------------------------------------
-- user_id = NULL  → danh mục mặc định của hệ thống (ai cũng thấy)
-- user_id = <uid> → danh mục riêng của từng người dùng
create table if not exists public.categories (
  id          uuid primary key default gen_random_uuid(),
  user_id     uuid references auth.users(id) on delete cascade,
  name        text not null check (char_length(btrim(name)) between 1 and 40),
  type        public.tx_type not null,
  emoji       text not null default '🎀',
  sort_order  int  not null default 0,
  created_at  timestamptz not null default now(),
  unique (id, type)                       -- để bảng giao dịch kiểm tra khớp loại
);

create unique index if not exists categories_unique_name
  on public.categories (coalesce(user_id, '00000000-0000-0000-0000-000000000000'::uuid), type, name);

-- 3. BẢNG GIAO DỊCH ----------------------------------------------------
create table if not exists public.transactions (
  id           uuid primary key default gen_random_uuid(),
  user_id      uuid not null default auth.uid() references auth.users(id) on delete cascade,
  type         public.tx_type   not null,
  category_id  uuid not null,
  title        text not null check (char_length(btrim(title)) between 1 and 80),
  amount       bigint not null check (amount > 0),           -- đơn vị: đồng
  occurred_on  date not null default current_date,
  status       public.tx_status not null default 'done',
  created_at   timestamptz not null default now(),
  updated_at   timestamptz not null default now(),
  -- danh mục phải cùng loại (thu/chi) với giao dịch
  foreign key (category_id, type) references public.categories (id, type)
);

create index if not exists tx_user_date_idx   on public.transactions (user_id, occurred_on desc);
create index if not exists tx_user_status_idx on public.transactions (user_id, status);

-- 4. TỰ CẬP NHẬT updated_at -------------------------------------------
create or replace function public.set_updated_at()
returns trigger language plpgsql set search_path = '' as $$
begin
  new.updated_at = now();
  return new;
end $$;

drop trigger if exists trg_tx_updated_at on public.transactions;
create trigger trg_tx_updated_at before update on public.transactions
  for each row execute function public.set_updated_at();

-- 5. BẢO MẬT HÀNG (Row Level Security) --------------------------------
alter table public.categories   enable row level security;
alter table public.transactions enable row level security;

drop policy if exists "cat_select" on public.categories;
drop policy if exists "cat_insert" on public.categories;
drop policy if exists "cat_update" on public.categories;
drop policy if exists "cat_delete" on public.categories;
create policy "cat_select" on public.categories for select to authenticated
  using (user_id is null or user_id = (select auth.uid()));
create policy "cat_insert" on public.categories for insert to authenticated
  with check (user_id = (select auth.uid()));
create policy "cat_update" on public.categories for update to authenticated
  using (user_id = (select auth.uid())) with check (user_id = (select auth.uid()));
create policy "cat_delete" on public.categories for delete to authenticated
  using (user_id = (select auth.uid()));

drop policy if exists "tx_all" on public.transactions;
create policy "tx_all" on public.transactions for all to authenticated
  using (user_id = (select auth.uid())) with check (user_id = (select auth.uid()));

-- 6. VIEW THỐNG KÊ (chỉ tính giao dịch "done"; security_invoker → vẫn bị RLS) ----
create or replace view public.v_monthly_summary with (security_invoker = true) as
select user_id,
       date_trunc('month', occurred_on)::date                         as month,
       coalesce(sum(amount) filter (where type = 'thu'), 0)::bigint   as total_thu,
       coalesce(sum(amount) filter (where type = 'chi'), 0)::bigint   as total_chi,
       count(*)                                                       as tx_count
from public.transactions
where status = 'done'
group by user_id, date_trunc('month', occurred_on);

create or replace view public.v_category_summary with (security_invoker = true) as
select t.user_id, t.type, c.name as category, c.emoji,
       sum(t.amount)::bigint as total, count(*) as tx_count
from public.transactions t
join public.categories c on c.id = t.category_id
where t.status = 'done'
group by t.user_id, t.type, c.name, c.emoji;

-- 7. DỮ LIỆU DANH MỤC MẶC ĐỊNH ----------------------------------------
insert into public.categories (user_id, name, type, emoji, sort_order) values
  (null, 'Ăn uống',       'chi', '🍜', 1),
  (null, 'Di chuyển',     'chi', '🛵', 2),
  (null, 'Học tập',       'chi', '📚', 3),
  (null, 'Mua sắm',       'chi', '🛍️', 4),
  (null, 'Giải trí',      'chi', '🎮', 5),
  (null, 'Hoá đơn',       'chi', '🧾', 6),
  (null, 'Khác',          'chi', '🎀', 7),
  (null, 'Tiền gia đình', 'thu', '🏠', 1),
  (null, 'Làm thêm',      'thu', '💼', 2),
  (null, 'Học bổng',      'thu', '🎓', 3),
  (null, 'Bán hàng',      'thu', '🛒', 4),
  (null, 'Khác',          'thu', '🎁', 5)
on conflict do nothing;
