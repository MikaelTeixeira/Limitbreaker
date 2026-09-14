import '../../features/ranking/domain/ranking_calculator.dart';
import '../models/models.dart';

/// Implementação temporária em memória para telas ainda sem backend completo.
class LocalAppRepository {
  final List<WorkoutSession> _workoutSessions = [];
  final List<FriendSummary> _friends = [];
  final List<FriendRequest> _requests = [];
  var _nextWorkoutSessionId = 1;

  Future<List<WorkoutPlan>> getPlans() async => const [];

  Future<List<WorkoutSession>> getSessions() async =>
      List.unmodifiable(_workoutSessions.reversed);

  Future<WorkoutSession> startWorkout(
    WorkoutPlan plan,
    DateTime startedAt,
  ) async {
    final session = WorkoutSession(
      id: 'workout-${_nextWorkoutSessionId++}',
      planId: plan.id,
      performedAt: startedAt,
      duration: Duration.zero,
    );
    _workoutSessions.add(session);
    return session;
  }

  Future<WorkoutSession> completeWorkout(
    String sessionId, {
    required Duration duration,
    required List<PerformedExercise> exercises,
    String? note,
    DateTime? completedAt,
  }) async {
    final index = _workoutSessions.indexWhere(
      (session) => session.id == sessionId,
    );
    if (index == -1) throw StateError('Sessão de treino não encontrada.');

    final previous = _workoutSessions[index];
    final session = WorkoutSession(
      id: previous.id,
      planId: previous.planId,
      performedAt: previous.performedAt,
      duration: duration,
      exercises: exercises,
      note: note,
      completedAt: completedAt ?? previous.performedAt.add(duration),
    );
    _workoutSessions[index] = session;
    return session;
  }

  Future<List<RadarAttribute>> getMuscleAttributes() async => const [];

  Future<List<RadarAttribute>> getCategoryAttributes() async => const [];

  Future<RankingCalculationResult> getCurrentRanking() async =>
      const RankingCalculator().calculate(const []);

  Future<List<Achievement>> getAchievements() async => const [];

  Future<List<FriendSummary>> getFriends() async => List.unmodifiable(_friends);

  Future<List<FriendRequest>> getRequests() async =>
      List.unmodifiable(_requests);

  Future<FriendRequest> sendRequest(String code) async {
    final cleanCode = code.trim().toUpperCase();
    if (cleanCode.isEmpty) {
      throw ArgumentError.value(code, 'code', 'Informe um código.');
    }

    final request = FriendRequest(
      id: 'request-${_requests.length + 1}',
      fromUserId: cleanCode,
      displayName: 'Convite enviado',
      status: FriendRequestStatus.pending,
      direction: FriendRequestDirection.sent,
    );
    _requests.add(request);
    return request;
  }

  Future<void> respondToRequest(
    String requestId,
    FriendRequestStatus status,
  ) async {
    final index = _requests.indexWhere((request) => request.id == requestId);
    if (index == -1) {
      throw StateError('Convite não encontrado.');
    }

    final current = _requests[index];
    _requests[index] = FriendRequest(
      id: current.id,
      fromUserId: current.fromUserId,
      displayName: current.displayName,
      status: status,
      direction: current.direction,
    );
    if (status == FriendRequestStatus.accepted &&
        current.direction == FriendRequestDirection.received) {
      _friends.add(
        FriendSummary(
          displayName: current.displayName,
          rankingLabel: 'Novo no círculo',
          recentActivity: 'Amizade confirmada agora',
        ),
      );
    }
  }
}
