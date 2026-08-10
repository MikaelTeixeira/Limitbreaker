import '../../../shared/models/models.dart';

abstract final class ExerciseCatalog {
  static const strengthExercises = <StrengthMuscleGroup, List<Exercise>>{
    StrengthMuscleGroup.chest: [
      Exercise(id: 'bench_press', name: 'Supino reto', muscleGroup: 'Peito'),
      Exercise(
        id: 'incline_press',
        name: 'Supino inclinado',
        muscleGroup: 'Peito',
      ),
      Exercise(
        id: 'cable_fly',
        name: 'Crucifixo no cabo',
        muscleGroup: 'Peito',
      ),
    ],
    StrengthMuscleGroup.shoulders: [
      Exercise(
        id: 'overhead_press',
        name: 'Desenvolvimento',
        muscleGroup: 'Ombro',
      ),
      Exercise(
        id: 'lateral_raise',
        name: 'Elevação lateral',
        muscleGroup: 'Ombro',
      ),
      Exercise(
        id: 'rear_delt_fly',
        name: 'Crucifixo inverso',
        muscleGroup: 'Ombro',
      ),
    ],
    StrengthMuscleGroup.legs: [
      Exercise(id: 'squat', name: 'Agachamento livre', muscleGroup: 'Pernas'),
      Exercise(id: 'leg_press', name: 'Leg press', muscleGroup: 'Pernas'),
      Exercise(
        id: 'romanian_deadlift',
        name: 'Levantamento terra romeno',
        muscleGroup: 'Pernas',
      ),
    ],
    StrengthMuscleGroup.biceps: [
      Exercise(id: 'barbell_curl', name: 'Rosca direta', muscleGroup: 'Bíceps'),
      Exercise(id: 'hammer_curl', name: 'Rosca martelo', muscleGroup: 'Bíceps'),
    ],
    StrengthMuscleGroup.triceps: [
      Exercise(
        id: 'triceps_pushdown',
        name: 'Tríceps pulley',
        muscleGroup: 'Tríceps',
      ),
      Exercise(
        id: 'skullcrusher',
        name: 'Tríceps testa',
        muscleGroup: 'Tríceps',
      ),
    ],
    StrengthMuscleGroup.abdomen: [
      Exercise(id: 'plank', name: 'Prancha', muscleGroup: 'Abdômen'),
      Exercise(
        id: 'cable_crunch',
        name: 'Abdominal no cabo',
        muscleGroup: 'Abdômen',
      ),
    ],
    StrengthMuscleGroup.back: [
      Exercise(
        id: 'lat_pulldown',
        name: 'Puxada frontal',
        muscleGroup: 'Costas',
      ),
      Exercise(
        id: 'barbell_row',
        name: 'Remada curvada',
        muscleGroup: 'Costas',
      ),
      Exercise(id: 'seated_row', name: 'Remada baixa', muscleGroup: 'Costas'),
    ],
  };

  static const activityOptions = <TrainingCategory, List<String>>{
    TrainingCategory.running: [
      'Corrida contínua',
      'Tiros',
      'Corrida em subida',
    ],
    TrainingCategory.cycling: [
      'Ciclismo de estrada',
      'Ciclismo indoor',
      'Mountain bike',
    ],
    TrainingCategory.swimming: [
      'Nado livre',
      'Nado costas',
      'Nado peito',
      'Borboleta',
    ],
  };
}
