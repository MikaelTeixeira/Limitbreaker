create table users (
  id uuid primary key default gen_random_uuid(),
  username text not null unique check (char_length(trim(username)) between 3 and 30),
  display_name text not null check (char_length(trim(display_name)) between 2 and 50),
  password_hash text not null,
  profile_id uuid unique references app_profiles(id) on delete set null,
  created_at timestamptz not null default now()
);

create index users_profile_idx on users (profile_id) where profile_id is not null;

insert into users (username, display_name, password_hash, profile_id)
select credentials.username, profiles.display_name, credentials.password_hash, credentials.profile_id
from local_credentials credentials
join app_profiles profiles on profiles.id = credentials.profile_id
on conflict (username) do nothing;
