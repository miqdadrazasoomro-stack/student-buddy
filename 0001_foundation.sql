-- Student Buddy - Phase 1 foundation schema
-- Run this once in Supabase Dashboard > SQL Editor.

-- 1. PROFILES -----------------------------------------------------------
create table if not exists public.profiles (
  id                 uuid primary key references auth.users(id) on delete cascade,
  full_name          text not null default '',
  grade              text,
  preferred_language text not null default 'english'
                     check (preferred_language in ('english','urdu','roman_urdu')),
  subjects           text[] not null default '{}',
  plan               text not null default 'free' check (plan in ('free','premium')),
  created_at         timestamptz not null default now(),
  updated_at         timestamptz not null default now()
);

alter table public.profiles enable row level security;

drop policy if exists "profiles_select_own" on public.profiles;
create policy "profiles_select_own" on public.profiles
  for select to authenticated using (auth.uid() = id);

drop policy if exists "profiles_update_own" on public.profiles;
create policy "profiles_update_own" on public.profiles
  for update to authenticated using (auth.uid() = id) with check (auth.uid() = id);

-- No INSERT/DELETE policies: rows are created by the trigger below and removed
-- only when the account is deleted (cascade from auth.users).

-- Users may edit only these columns. This stops anyone from giving
-- themselves the "premium" plan from the app.
revoke update on public.profiles from anon, authenticated;
grant  update (full_name, grade, preferred_language, subjects)
  on public.profiles to authenticated;

-- 2. AUTO-CREATE PROFILE ON SIGN UP -------------------------------------
create or replace function public.handle_new_user()
returns trigger language plpgsql security definer set search_path = public as $$
begin
  insert into public.profiles (id, full_name)
  values (new.id, coalesce(new.raw_user_meta_data->>'full_name', ''));
  return new;
end;
$$;

drop trigger if exists on_auth_user_created on auth.users;
create trigger on_auth_user_created
  after insert on auth.users
  for each row execute function public.handle_new_user();

-- 3. KEEP updated_at FRESH ------------------------------------------------
create or replace function public.set_updated_at()
returns trigger language plpgsql as $$
begin new.updated_at = now(); return new; end;
$$;

drop trigger if exists profiles_set_updated_at on public.profiles;
create trigger profiles_set_updated_at
  before update on public.profiles
  for each row execute function public.set_updated_at();

-- 4. AI USAGE LOG (powers daily limits / future free vs premium plans) ----
create table if not exists public.ai_usage (
  id         bigint generated always as identity primary key,
  user_id    uuid not null references auth.users(id) on delete cascade,
  feature    text not null default 'chat',
  created_at timestamptz not null default now()
);
create index if not exists ai_usage_user_day_idx on public.ai_usage (user_id, created_at desc);

alter table public.ai_usage enable row level security;

drop policy if exists "ai_usage_select_own" on public.ai_usage;
create policy "ai_usage_select_own" on public.ai_usage
  for select to authenticated using (auth.uid() = user_id);
-- Only the Edge Function (service role) writes to this table.
