import 'package:flutter_test/flutter_test.dart';
import 'package:limit_breaker/features/exercises/data/exercise_catalog.dart';
import 'package:limit_breaker/shared/models/models.dart';

void main() {
  test('catálogo cobre os sete grupos musculares solicitados', () {
    expect(
      ExerciseCatalog.strengthExercises.keys,
      containsAll(StrengthMuscleGroup.values),
    );
    expect(
      ExerciseCatalog.strengthExercises.values.every(
        (items) => items.isNotEmpty,
      ),
      isTrue,
    );
  });

  test('categorias aeróbicas apresentam opções de atividade', () {
    expect(
      ExerciseCatalog.activityOptions.keys,
      containsAll([
        TrainingCategory.running,
        TrainingCategory.cycling,
        TrainingCategory.swimming,
      ]),
    );
  });
}
