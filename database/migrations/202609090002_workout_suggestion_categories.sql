alter table workout_suggestions
  drop constraint workout_suggestions_training_style_check;

alter table workout_suggestions
  add constraint workout_suggestions_training_style_check check (
    training_style in ('strength', 'running', 'cycling', 'swimming')
  );
