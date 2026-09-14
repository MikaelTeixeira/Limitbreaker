import 'package:flutter_test/flutter_test.dart';
import 'package:limit_breaker/shared/models/models.dart';
import 'package:limit_breaker/shared/repositories/repositories.dart';

void main() {
  const plan = WorkoutPlan(
    id: 'push',
    name: 'Push',
    groups: ['Peito'],
    exerciseCount: 1,
  );

  test('inicia e conclui a sessão provisória', () async {
    final data = LocalAppRepository();
    final startedAt = DateTime(2026, 8, 6, 8);
    final started = await data.startWorkout(plan, startedAt);
    final completed = await data.completeWorkout(
      started.id,
      duration: const Duration(minutes: 48),
      exercises: const [],
      note: 'Boa execução.',
    );

    expect(completed.completedAt, startedAt.add(const Duration(minutes: 48)));
    expect((await data.getSessions()).single.note, 'Boa execução.');
  });

  test('falha ao concluir uma sessão inexistente', () async {
    final data = LocalAppRepository();
    await expectLater(
      data.completeWorkout(
        'ausente',
        duration: Duration.zero,
        exercises: const [],
      ),
      throwsA(isA<StateError>()),
    );
  });
}
