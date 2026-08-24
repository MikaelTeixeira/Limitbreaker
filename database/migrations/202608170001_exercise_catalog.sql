create table exercise_categories (
  id uuid primary key default gen_random_uuid(),
  name text not null unique check (char_length(trim(name)) between 2 and 50)
);

create table exercises (
  id uuid primary key default gen_random_uuid(),
  name text not null check (char_length(trim(name)) between 2 and 100),
  exercise_category_id uuid not null references exercise_categories(id) on delete restrict,
  unique (name, exercise_category_id)
);

create index exercises_category_idx on exercises (exercise_category_id);
create index exercises_name_idx on exercises (name);

insert into exercise_categories (name) values
  ('Peito'), ('Costas'), ('Pernas'), ('Ombros'), ('Bíceps'), ('Tríceps'),
  ('Antebraços'), ('Abdômen'), ('Glúteos'), ('Panturrilhas')
on conflict (name) do nothing;

with catalog(category_name, exercise_name) as (
  values
    ('Peito', 'Supino reto com barra'),
    ('Peito', 'Supino reto com halteres'),
    ('Peito', 'Supino inclinado com barra'),
    ('Peito', 'Supino inclinado com halteres'),
    ('Peito', 'Supino declinado com barra'),
    ('Peito', 'Crucifixo com halteres'),
    ('Peito', 'Crucifixo no cabo'),
    ('Peito', 'Crossover alto'),
    ('Peito', 'Crossover baixo'),
    ('Peito', 'Peck deck'),
    ('Peito', 'Flexão de braços'),
    ('Peito', 'Paralelas para peito'),
    ('Costas', 'Puxada frontal aberta'),
    ('Costas', 'Puxada frontal neutra'),
    ('Costas', 'Puxada supinada'),
    ('Costas', 'Remada curvada com barra'),
    ('Costas', 'Remada unilateral com halter'),
    ('Costas', 'Remada baixa no cabo'),
    ('Costas', 'Remada cavalinho'),
    ('Costas', 'Remada articulada'),
    ('Costas', 'Pullover no cabo'),
    ('Costas', 'Levantamento terra'),
    ('Costas', 'Hiperextensão lombar'),
    ('Pernas', 'Agachamento livre'),
    ('Pernas', 'Agachamento frontal'),
    ('Pernas', 'Agachamento hack'),
    ('Pernas', 'Leg press 45 graus'),
    ('Pernas', 'Leg press horizontal'),
    ('Pernas', 'Cadeira extensora'),
    ('Pernas', 'Cadeira flexora'),
    ('Pernas', 'Mesa flexora'),
    ('Pernas', 'Levantamento terra romeno'),
    ('Pernas', 'Stiff com halteres'),
    ('Pernas', 'Afundo com halteres'),
    ('Pernas', 'Afundo búlgaro'),
    ('Pernas', 'Passada caminhando'),
    ('Pernas', 'Step-up'),
    ('Pernas', 'Adução na máquina'),
    ('Pernas', 'Abdução na máquina'),
    ('Ombros', 'Desenvolvimento com barra'),
    ('Ombros', 'Desenvolvimento com halteres'),
    ('Ombros', 'Desenvolvimento na máquina'),
    ('Ombros', 'Elevação lateral com halteres'),
    ('Ombros', 'Elevação lateral no cabo'),
    ('Ombros', 'Elevação frontal com halteres'),
    ('Ombros', 'Crucifixo inverso'),
    ('Ombros', 'Face pull'),
    ('Ombros', 'Remada alta'),
    ('Bíceps', 'Rosca direta com barra'),
    ('Bíceps', 'Rosca direta na barra W'),
    ('Bíceps', 'Rosca alternada com halteres'),
    ('Bíceps', 'Rosca martelo'),
    ('Bíceps', 'Rosca concentrada'),
    ('Bíceps', 'Rosca Scott'),
    ('Bíceps', 'Rosca no cabo'),
    ('Bíceps', 'Rosca inclinada com halteres'),
    ('Tríceps', 'Tríceps pulley com barra'),
    ('Tríceps', 'Tríceps pulley com corda'),
    ('Tríceps', 'Tríceps testa com barra W'),
    ('Tríceps', 'Tríceps francês com halter'),
    ('Tríceps', 'Tríceps coice'),
    ('Tríceps', 'Mergulho no banco'),
    ('Tríceps', 'Paralelas para tríceps'),
    ('Tríceps', 'Tríceps máquina'),
    ('Antebraços', 'Rosca de punho com barra'),
    ('Antebraços', 'Rosca de punho inversa'),
    ('Antebraços', 'Rosca martelo inversa'),
    ('Antebraços', 'Farmer walk'),
    ('Abdômen', 'Abdominal crunch'),
    ('Abdômen', 'Abdominal no cabo'),
    ('Abdômen', 'Abdominal infra na barra'),
    ('Abdômen', 'Elevação de pernas'),
    ('Abdômen', 'Prancha'),
    ('Abdômen', 'Prancha lateral'),
    ('Abdômen', 'Abdominal bicicleta'),
    ('Abdômen', 'Ab wheel'),
    ('Glúteos', 'Elevação pélvica com barra'),
    ('Glúteos', 'Glute bridge na máquina'),
    ('Glúteos', 'Coice no cabo'),
    ('Glúteos', 'Coice na máquina'),
    ('Glúteos', 'Pull-through no cabo'),
    ('Glúteos', 'Abdução de quadril no cabo'),
    ('Panturrilhas', 'Elevação de panturrilha em pé'),
    ('Panturrilhas', 'Elevação de panturrilha sentado'),
    ('Panturrilhas', 'Panturrilha no leg press'),
    ('Panturrilhas', 'Panturrilha no smith')
)
insert into exercises (name, exercise_category_id)
select catalog.exercise_name, categories.id
from catalog
join exercise_categories categories on categories.name = catalog.category_name
on conflict (name, exercise_category_id) do nothing;
