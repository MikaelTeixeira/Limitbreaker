/// Plano de treino sugerido ou criado para a pessoa.
class WorkoutPlan {
  const WorkoutPlan({
    required this.id,
    required this.name,
    required this.groups,
    required this.exerciseCount,
    this.estimatedMinutes,
    this.exercises = const [],
  });

  final String id;
  final String name;
  final List<String> groups;
  final int exerciseCount;
  final int? estimatedMinutes;
  final List<PlannedExercise> exercises;
}

/// Exercício planejado dentro de um plano de treino.
class PlannedExercise {
  const PlannedExercise({required this.exercise, required this.targetSets});

  final Exercise exercise;
  final int targetSets;
}

/// Exercício do catálogo de musculação.
class Exercise {
  const Exercise({
    required this.id,
    required this.name,
    required this.muscleGroup,
  });

  final String id;
  final String name;
  final String muscleGroup;
}

/// Categorias de treino registráveis manualmente.
enum TrainingCategory { strength, running, cycling, swimming }

/// Texto de apresentação de cada categoria de treino.
extension TrainingCategoryDetails on TrainingCategory {
  String get label => switch (this) {
    TrainingCategory.strength => 'Musculação',
    TrainingCategory.running => 'Corrida',
    TrainingCategory.cycling => 'Ciclismo',
    TrainingCategory.swimming => 'Natação',
  };
}

/// Grupos musculares disponíveis para treinos de força.
enum StrengthMuscleGroup {
  chest,
  shoulders,
  legs,
  forearms,
  biceps,
  triceps,
  abdomen,
  back,
}

/// Texto de apresentação de cada grupo muscular.
extension StrengthMuscleGroupDetails on StrengthMuscleGroup {
  String get label => switch (this) {
    StrengthMuscleGroup.chest => 'Peito',
    StrengthMuscleGroup.shoulders => 'Ombro',
    StrengthMuscleGroup.legs => 'Pernas',
    StrengthMuscleGroup.forearms => 'Antebra\u00e7o',
    StrengthMuscleGroup.biceps => 'Bíceps',
    StrengthMuscleGroup.triceps => 'Tríceps',
    StrengthMuscleGroup.abdomen => 'Abdômen',
    StrengthMuscleGroup.back => 'Costas',
  };
}

/// Registro pontual de carga e repetições de um exercício.
class StrengthExerciseLog {
  const StrengthExerciseLog({
    required this.id,
    required this.exerciseId,
    required this.loadKg,
    required this.repetitions,
    required this.performedAt,
  });

  final String id;
  final String exerciseId;
  final double loadKg;
  final int repetitions;
  final DateTime performedAt;
}

/// Série realizada em um exercício de musculação.
class ExerciseSet {
  const ExerciseSet({
    required this.repetitions,
    required this.loadKg,
    this.completed = true,
  });

  final int repetitions;
  final double loadKg;
  final bool completed;
}

/// Exercício realizado em uma sessão de treino.
class PerformedExercise {
  const PerformedExercise({required this.exercise, required this.sets});

  final Exercise exercise;
  final List<ExerciseSet> sets;
}

/// Sessão de treino iniciada ou concluída pela pessoa.
class WorkoutSession {
  const WorkoutSession({
    required this.id,
    required this.planId,
    required this.performedAt,
    required this.duration,
    this.exercises = const [],
    this.completedAt,
    this.note,
  });

  final String id;
  final String planId;
  final DateTime performedAt;
  final Duration duration;
  final List<PerformedExercise> exercises;
  final DateTime? completedAt;
  final String? note;
}
