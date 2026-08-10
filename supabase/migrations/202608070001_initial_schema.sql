create extension if not exists pgcrypto;

create table public.profiles (
  id uuid primary key references auth.users(id) on delete cascade,
  display_name text not null check (char_length(display_name) between 2 and 50),
  avatar_path text,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create table public.activity_categories (
  id text primary key,
  name text not null unique,
  created_at timestamptz not null default now()
);

create table public.workout_plans (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references public.profiles(id) on delete cascade,
  name text not null check (char_length(name) between 1 and 100),
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create table public.workout_sessions (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references public.profiles(id) on delete cascade,
  plan_id uuid references public.workout_plans(id) on delete set null,
  started_at timestamptz not null,
  completed_at timestamptz,
  duration_seconds integer not null default 0 check (duration_seconds >= 0),
  note text check (char_length(note) <= 1000)
);

create table public.activity_sessions (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references public.profiles(id) on delete cascade,
  category_id text not null references public.activity_categories(id),
  performed_at timestamptz not null,
  duration_seconds integer check (duration_seconds >= 0),
  distance_km numeric(7,2) check (distance_km >= 0),
  intensity smallint check (intensity between 1 and 10)
);

create table public.friend_requests (
  id uuid primary key default gen_random_uuid(),
  sender_id uuid not null references public.profiles(id) on delete cascade,
  recipient_id uuid not null references public.profiles(id) on delete cascade,
  status text not null default 'pending' check (status in ('pending','accepted','declined')),
  created_at timestamptz not null default now(),
  unique(sender_id, recipient_id),
  check (sender_id <> recipient_id)
);

create index workout_sessions_user_started_idx on public.workout_sessions(user_id, started_at desc);
create index activity_sessions_user_performed_idx on public.activity_sessions(user_id, performed_at desc);
create index friend_requests_recipient_status_idx on public.friend_requests(recipient_id, status);

alter table public.profiles enable row level security;
alter table public.activity_categories enable row level security;
alter table public.workout_plans enable row level security;
alter table public.workout_sessions enable row level security;
alter table public.activity_sessions enable row level security;
alter table public.friend_requests enable row level security;

create policy "Users manage own profile" on public.profiles for all to authenticated using ((select auth.uid()) = id) with check ((select auth.uid()) = id);
create policy "Authenticated users read categories" on public.activity_categories for select to authenticated using (true);
create policy "Users manage own plans" on public.workout_plans for all to authenticated using ((select auth.uid()) = user_id) with check ((select auth.uid()) = user_id);
create policy "Users manage own workout sessions" on public.workout_sessions for all to authenticated using ((select auth.uid()) = user_id) with check ((select auth.uid()) = user_id);
create policy "Users manage own activity sessions" on public.activity_sessions for all to authenticated using ((select auth.uid()) = user_id) with check ((select auth.uid()) = user_id);
create policy "Users read related requests" on public.friend_requests for select to authenticated using ((select auth.uid()) in (sender_id, recipient_id));
create policy "Users create own requests" on public.friend_requests for insert to authenticated with check ((select auth.uid()) = sender_id);
create policy "Recipients respond to requests" on public.friend_requests for update to authenticated using ((select auth.uid()) = recipient_id) with check ((select auth.uid()) = recipient_id);
