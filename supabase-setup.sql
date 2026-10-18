-- Supabase SQL Editor 에 붙여넣고 Run 하세요. (여러 번 실행해도 안전합니다)

create table if not exists public.registrations (
  id          uuid primary key default gen_random_uuid(),
  created_at  timestamptz not null default now(),
  name        text not null check (char_length(name) between 1 and 100),
  phone       text not null check (char_length(phone) between 8 and 20),
  email       text check (email is null or char_length(email) <= 200),
  interest    text check (interest is null or char_length(interest) <= 100),
  message     text check (message is null or char_length(message) <= 500),
  status      text not null default '신규' check (status in ('신규', '상담중', '등록완료')),
  memo        text check (memo is null or char_length(memo) <= 1000)
);

create index if not exists registrations_created_at_idx on public.registrations (created_at desc);

alter table public.registrations enable row level security;

-- 수강생(비로그인): 신청서 "등록"만 가능. 조회·수정·삭제는 불가.
drop policy if exists "anon can insert registrations" on public.registrations;
create policy "anon can insert registrations"
  on public.registrations for insert
  to anon
  with check (status = '신규' and memo is null);

-- 관리자(로그인한 사용자): 조회·수정·삭제 가능
drop policy if exists "admin can select registrations" on public.registrations;
create policy "admin can select registrations"
  on public.registrations for select
  to authenticated
  using (true);

drop policy if exists "admin can update registrations" on public.registrations;
create policy "admin can update registrations"
  on public.registrations for update
  to authenticated
  using (true) with check (true);

drop policy if exists "admin can delete registrations" on public.registrations;
create policy "admin can delete registrations"
  on public.registrations for delete
  to authenticated
  using (true);

revoke all on public.registrations from anon, authenticated;
grant insert on public.registrations to anon;
grant select, update, delete on public.registrations to authenticated;
