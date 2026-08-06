import 'package:flutter_test/flutter_test.dart';
import 'package:limit_breaker/features/workouts/data/in_memory_workout_repository.dart';
import 'package:limit_breaker/shared/models/models.dart';

void main() {
  const exercise = Exercise(
    id: 'bench',
    name: 'Supino reto',
    muscleGroup: 'Peito',
  );
  const plan = WorkoutPlan(
    id: 'push',
    name: 'Push',
    groups: ['Peito'],
    exerciseCount: 1,
  );

  test('inicia e conclui uma sessão sem alterar o plano', () async {
    final repository = InMemoryWorkoutRepository(plans: [plan]);
    final startedAt = DateTime(2026, 8, 6, 8);

    final started = await repository.startWorkout(plan, startedAt);
    final completed = await repository.completeWorkout(
      started.id,
      duration: const Duration(minutes: 48),
      exercises: const [
        PerformedExercise(
          exercise: exercise,
          sets: [ExerciseSet(repetitions: 10, loadKg: 70)],
        ),
      ],
      note: 'Boa execução.',
    );

    expect((await repository.getPlans()).single.name, 'Push');
    expect(completed.completedAt, startedAt.add(const Duration(minutes: 48)));
    expect(completed.exercises.single.sets.single.loadKg, 70);
    expect((await repository.getSessions()).single.note, 'Boa execução.');
  });

  test('falha de forma explícita ao concluir sessão inexistente', () async {
    final repository = InMemoryWorkoutRepository();
    await expectLater(
      repository.completeWorkout(
        'ausente',
        duration: Duration.zero,
        exercises: const [],
      ),
      throwsA(isA<StateError>()),
    );
  });
}
