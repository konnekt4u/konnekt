-- Konnekt creator discovery and portfolio foundation
-- Additive migration; existing Konnekt tables and rows are preserved.
alter table public.profiles
  add column if not exists talents text[] not null default '{}',
  add column if not exists skills text[] not null default '{}',
  add column if not exists study_year text,
  add column if not exists graduation_year integer,
  add column if not exists experience_level text,
  add column if not exists experience_summary text,
  add column if not exists country text,
  add column if not exists state text,
  add column if not exists city text,
  add column if not exists age_range text;

alter table public.profiles
  drop constraint if exists profiles_study_year_check,
  add constraint profiles_study_year_check check (study_year is null or study_year in ('1st Year','2nd Year','3rd Year','4th Year','Graduated','Other')),
  drop constraint if exists profiles_experience_level_check,
  add constraint profiles_experience_level_check check (experience_level is null or experience_level in ('No experience','Beginner','Intermediate','Experienced')),
  drop constraint if exists profiles_age_range_check,
  add constraint profiles_age_range_check check (age_range is null or age_range in ('Under 18','18–20','21–25','26–30','31–35','36+')),
  drop constraint if exists profiles_graduation_year_check,
  add constraint profiles_graduation_year_check check (graduation_year is null or graduation_year between 1950 and 2100);

create index if not exists profiles_talents_gin_idx on public.profiles using gin (talents);
create index if not exists profiles_skills_gin_idx on public.profiles using gin (skills);
create index if not exists profiles_location_idx on public.profiles (country,state,city);
create index if not exists profiles_discovery_filters_idx on public.profiles (study_year,experience_level,age_range) where is_public=true;

-- Birth date is private and is never selected by the public creator directory.
create table if not exists public.creator_private_details (
  creator_id uuid primary key references auth.users(id) on delete cascade,
  date_of_birth date,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);
alter table public.creator_private_details enable row level security;
drop policy if exists "Creators manage their own private details" on public.creator_private_details;
create policy "Creators manage their own private details" on public.creator_private_details
  for all to authenticated using ((select auth.uid())=creator_id) with check ((select auth.uid())=creator_id);
grant select,insert,update,delete on public.creator_private_details to authenticated;

create table if not exists public.creator_portfolio (
  id uuid primary key default gen_random_uuid(),
  creator_id uuid not null references auth.users(id) on delete cascade,
  title text not null check (char_length(title) between 1 and 160),
  category text not null,
  role text not null default '',
  description text not null default '' check (char_length(description)<=3000),
  media_url text not null default '',
  project_url text not null default '',
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);
create index if not exists creator_portfolio_creator_idx on public.creator_portfolio (creator_id,created_at desc);
alter table public.creator_portfolio enable row level security;
drop policy if exists "Public portfolios are readable" on public.creator_portfolio;
create policy "Public portfolios are readable" on public.creator_portfolio for select to anon,authenticated
  using (exists(select 1 from public.profiles p where p.id=creator_id and (p.is_public=true or p.id=(select auth.uid()))));
drop policy if exists "Creators add their own portfolio items" on public.creator_portfolio;
create policy "Creators add their own portfolio items" on public.creator_portfolio for insert to authenticated with check ((select auth.uid())=creator_id);
drop policy if exists "Creators update their own portfolio items" on public.creator_portfolio;
create policy "Creators update their own portfolio items" on public.creator_portfolio for update to authenticated using ((select auth.uid())=creator_id) with check ((select auth.uid())=creator_id);
drop policy if exists "Creators delete their own portfolio items" on public.creator_portfolio;
create policy "Creators delete their own portfolio items" on public.creator_portfolio for delete to authenticated using ((select auth.uid())=creator_id);
grant select on public.creator_portfolio to anon,authenticated;
grant insert,update,delete on public.creator_portfolio to authenticated;

grant select on public.profiles to anon,authenticated;
grant insert,update on public.profiles to authenticated;
