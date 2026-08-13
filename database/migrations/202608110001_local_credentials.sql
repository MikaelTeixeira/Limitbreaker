create table local_credentials (
  profile_id uuid primary key references app_profiles(id) on delete cascade,
  username text not null unique check (char_length(username) between 3 and 30),
  password_hash text not null,
  created_at timestamptz not null default now()
);
