import '../../../shared/models/models.dart';
import '../../../shared/repositories/repositories.dart';

class InMemoryWorkoutRepository implements WorkoutRepository {
  InMemoryWorkoutRepository({List<WorkoutPlan>? plans})
    : _plans = plans ?? const [];

  final List<WorkoutPlan> _plans;
  final List<WorkoutSession> _sessions = [];
  var _nextId = 1;

  @override
  Future<List<WorkoutPlan>> getPlans() async => List.unmodifiable(_plans);

  @override
  Future<List<WorkoutSession>> getSessions() async =>
      List.unmodifiable(_sessions.reversed);

  @override
  Future<WorkoutSession> startWorkout(
    WorkoutPlan plan,
    DateTime startedAt,
  ) async {
    final session = WorkoutSession(
      id: 'workout-${_nextId++}',
      planId: plan.id,
      performedAt: startedAt,
      duration: Duration.zero,
    );
    _sessions.add(session);
    return session;
  }

  @override
  Future<WorkoutSession> completeWorkout(
    String sessionId, {
    required Duration duration,
    required List<PerformedExercise> exercises,
    String? note,
    DateTime? completedAt,
  }) async {
    final index = _sessions.indexWhere((session) => session.id == sessionId);
    if (index == -1) {
      throw StateError('Sessão de treino não encontrada.');
    }
    final current = _sessions[index];
    final completed = WorkoutSession(
      id: current.id,
      planId: current.planId,
      performedAt: current.performedAt,
      duration: duration,
      exercises: List.unmodifiable(exercises),
      note: note,
      completedAt: completedAt ?? current.performedAt.add(duration),
    );
    _sessions[index] = completed;
    return completed;
  }
}
