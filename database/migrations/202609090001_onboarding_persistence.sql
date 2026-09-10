alter table app_profiles
  add column goal text,
  add column primary_sport text,
  add column secondary_sport text,
  add column tertiary_sport text,
  add column onboarding_completed_at timestamptz;

alter table app_profiles
  add constraint app_profiles_goal_check check (
    goal is null or goal in (
      'gain_muscle',
      'lose_fat',
      'conditioning',
      'sports_performance',
      'health',
      'maintain_fitness'
    )
  ),
  add constraint app_profiles_primary_sport_check check (
    primary_sport is null or primary_sport in (
      'strength', 'running', 'cycling', 'swimming', 'football', 'martial_arts'
    )
  ),
  add constraint app_profiles_secondary_sport_check check (
    secondary_sport is null or secondary_sport in (
      'strength', 'running', 'cycling', 'swimming', 'football', 'martial_arts'
    )
  ),
  add constraint app_profiles_tertiary_sport_check check (
    tertiary_sport is null or tertiary_sport in (
      'strength', 'running', 'cycling', 'swimming', 'football', 'martial_arts'
    )
  ),
  add constraint app_profiles_distinct_sports_check check (
    primary_sport is null or secondary_sport is null or tertiary_sport is null or
    (primary_sport <> secondary_sport and
     primary_sport <> tertiary_sport and
     secondary_sport <> tertiary_sport)
  );
