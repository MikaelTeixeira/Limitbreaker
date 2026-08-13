create table local_sessions (
  token_hash text primary key,
  profile_id uuid not null references app_profiles(id) on delete cascade,
  expires_at timestamptz not null,
  created_at timestamptz not null default now()
);

create table workout_sessions (
  id uuid primary key default gen_random_uuid(),
  profile_id uuid not null references app_profiles(id) on delete cascade,
  category text not null check (category in ('strength', 'running', 'cycling', 'swimming')),
  performed_at timestamptz not null,
  duration_seconds integer not null default 0 check (duration_seconds >= 0),
  distance_meters numeric(10, 2),
  created_at timestamptz not null default now()
);

create table workout_exercises (
  id uuid primary key default gen_random_uuid(),
  workout_session_id uuid not null references workout_sessions(id) on delete cascade,
  exercise_name text not null check (char_length(exercise_name) between 2 and 100),
  muscle_group text not null check (char_length(muscle_group) between 2 and 50)
);

create table workout_sets (
  id uuid primary key default gen_random_uuid(),
  workout_exercise_id uuid not null references workout_exercises(id) on delete cascade,
  set_number smallint not null check (set_number between 1 and 100),
  repetitions smallint not null check (repetitions between 1 and 1000),
  load_kg numeric(7, 2) not null check (load_kg >= 0 and load_kg <= 2000),
  unique (workout_exercise_id, set_number)
);

create index workout_sessions_profile_performed_idx
  on workout_sessions (profile_id, performed_at desc);
create index local_sessions_profile_expires_idx
  on local_sessions (profile_id, expires_at);
