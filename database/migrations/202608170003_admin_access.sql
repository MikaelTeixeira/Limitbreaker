create type user_type as enum ('standard', 'administrator');

alter table users
  add column user_type user_type not null default 'standard',
  add column is_active boolean not null default true;

alter table local_sessions
  add column user_id uuid references users(id) on delete cascade;

update local_sessions sessions
set user_id = users.id
from users
where users.profile_id = sessions.profile_id;

delete from local_sessions where user_id is null;

alter table local_sessions
  alter column user_id set not null,
  alter column profile_id drop not null;

create index local_sessions_user_expires_idx
  on local_sessions (user_id, expires_at);

create table app_events (
  id uuid primary key default gen_random_uuid(),
  title text not null check (char_length(trim(title)) between 3 and 100),
  status text not null check (status in ('scheduled', 'active', 'finished')),
  started_at timestamptz,
  finished_at timestamptz,
  created_by uuid not null references users(id) on delete restrict,
  created_at timestamptz not null default now()
);

update users
set user_type = 'administrator'
where username = 'mikael.teixeira';
