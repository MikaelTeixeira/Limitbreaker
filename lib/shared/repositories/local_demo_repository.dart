import '../../features/ranking/domain/ranking_calculator.dart';
import '../models/models.dart';
import 'repository_contracts.dart';

/// Implementação temporária em memória para telas ainda sem backend completo.
class LocalAppRepository
    implements
        AuthenticationRepository,
        ProfileRepository,
        HealthRepository,
        WorkoutRepository,
        ActivityRepository,
        DashboardRepository,
        RankingRepository,
        AchievementRepository,
        FriendRepository,
        ChatRepository {
  final List<WorkoutSession> _workoutSessions = [];
  final List<ActivitySession> _activities = [];
  final List<FriendSummary> _friends = [];
  final List<FriendRequest> _requests = [];
  var _nextWorkoutSessionId = 1;
  var _nextActivityId = 1;

  @override
  Future<UserProfile?> currentUser() async => null;

  @override
  Future<void> signOut() async {}

  @override
  Future<UserProfile> getProfile() async =>
      throw StateError('Nenhum perfil foi cadastrado.');

  @override
  Future<HealthProfile?> getHealthProfile() async => null;

  @override
  Future<List<WorkoutPlan>> getPlans() async => const [];

  @override
  Future<List<WorkoutSession>> getSessions() async =>
      List.unmodifiable(_workoutSessions.reversed);

  @override
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

  @override
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

  @override
  Future<List<ActivitySession>> getActivities() async =>
      List.unmodifiable(_activities.reversed);

  @override
  Future<ActivitySession> addActivity({
    required String categoryId,
    required DateTime performedAt,
    Duration? duration,
    double? distanceKm,
    int? intensity,
  }) async {
    final activity = ActivitySession(
      id: 'activity-${_nextActivityId++}',
      categoryId: categoryId,
      performedAt: performedAt,
      duration: duration,
      distanceKm: distanceKm,
      intensity: intensity,
    );
    _activities.add(activity);
    return activity;
  }

  @override
  Future<List<PersonalRecord>> getPersonalRecords() async {
    final longestRun = _activities
        .where(
          (item) => item.categoryId == 'running' && item.distanceKm != null,
        )
        .fold<double>(
          0,
          (max, item) => item.distanceKm! > max ? item.distanceKm! : max,
        );
    if (longestRun == 0) return const [];

    return [
      PersonalRecord(
        id: 'longest-run',
        label: 'Maior corrida',
        value: longestRun,
        achievedAt: _activities
            .firstWhere(
              (item) =>
                  item.categoryId == 'running' && item.distanceKm == longestRun,
            )
            .performedAt,
      ),
    ];
  }

  @override
  Future<WorkoutPlan?> getTodayWorkout() async => null;

  @override
  Future<List<RadarAttribute>> getMuscleAttributes() async => const [];

  @override
  Future<List<RadarAttribute>> getCategoryAttributes() async => const [];

  @override
  Future<RankingCalculationResult> getCurrentRanking() async =>
      const RankingCalculator().calculate(const []);

  @override
  Future<List<Achievement>> getAchievements() async => const [];

  @override
  Future<List<FriendSummary>> getFriends() async => List.unmodifiable(_friends);

  @override
  Future<List<FriendRequest>> getRequests() async =>
      List.unmodifiable(_requests);

  @override
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

  @override
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

  @override
  Future<List<ChatConversation>> getConversations() async => const [];
}
