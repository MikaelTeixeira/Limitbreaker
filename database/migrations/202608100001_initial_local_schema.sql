create extension if not exists pgcrypto;

create table app_profiles (
  id uuid primary key default gen_random_uuid(),
  email text not null unique check (char_length(email) between 5 and 320),
  display_name text not null check (char_length(display_name) between 2 and 50),
  age smallint not null check (age between 13 and 120),
  height_cm numeric(5, 1) not null check (height_cm between 80 and 250),
  weight_kg numeric(5, 1) not null check (weight_kg between 20 and 400),
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create table health_assessments (
  id uuid primary key default gen_random_uuid(),
  profile_id uuid not null unique references app_profiles(id) on delete cascade,
  activity_baseline text not null check (activity_baseline in ('active', 'sedentary')),
  requires_gentle_training boolean not null default false,
  training_profile smallint not null check (training_profile between 1 and 4),
  consent_version text not null check (char_length(consent_version) between 1 and 50),
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create table health_disclosures (
  id uuid primary key default gen_random_uuid(),
  assessment_id uuid not null references health_assessments(id) on delete cascade,
  disclosure_kind text not null check (disclosure_kind in ('personal', 'family')),
  question_id text not null check (char_length(question_id) between 1 and 80),
  status text not null check (status in ('no_problem', 'reported')),
  description text,
  created_at timestamptz not null default now(),
  unique (assessment_id, disclosure_kind, question_id),
  check (
    (status = 'no_problem' and description is null) or
    (status = 'reported' and char_length(trim(description)) between 3 and 1000)
  )
);

create table workout_suggestions (
  id uuid primary key default gen_random_uuid(),
  profile_id uuid not null references app_profiles(id) on delete cascade,
  training_style text not null check (
    training_style in ('strength', 'running', 'conditioning', 'general_health')
  ),
  muscle_group text not null check (char_length(muscle_group) between 2 and 50),
  training_profile smallint not null check (training_profile between 1 and 4),
  suggestion jsonb not null,
  created_at timestamptz not null default now()
);

create index health_disclosures_assessment_kind_idx
  on health_disclosures (assessment_id, disclosure_kind);
create index workout_suggestions_profile_created_idx
  on workout_suggestions (profile_id, created_at desc);

revoke all on all tables in schema public from public;
