import '../../features/ranking/domain/ranking_calculator.dart';
import '../models/models.dart';

/// Contrato para autenticação e sessão do usuário.
abstract interface class AuthenticationRepository {
  /// Retorna a pessoa autenticada, ou nulo quando não há sessão ativa.
  Future<UserProfile?> currentUser();

  /// Encerra a sessão local.
  Future<void> signOut();
}

/// Contrato para persistir a conclusão do onboarding.
abstract interface class OnboardingRepository {
  /// Informa se o onboarding já foi finalizado neste dispositivo.
  Future<bool> isComplete();

  /// Marca o onboarding como concluído neste dispositivo.
  Future<void> complete();
}

/// Contrato de leitura do perfil da pessoa.
abstract interface class ProfileRepository {
  /// Busca os dados do perfil autenticado.
  Future<UserProfile> getProfile();
}

/// Contrato de leitura das informações de saúde.
abstract interface class HealthRepository {
  /// Busca o perfil de saúde, quando ele já existir.
  Future<HealthProfile?> getHealthProfile();
}

/// Contrato para planos e sessões de treino.
abstract interface class WorkoutRepository {
  /// Lista os planos de treino disponíveis.
  Future<List<WorkoutPlan>> getPlans();

  /// Lista as sessões de treino registradas.
  Future<List<WorkoutSession>> getSessions();

  /// Inicia uma sessão a partir de um plano.
  Future<WorkoutSession> startWorkout(WorkoutPlan plan, DateTime startedAt);

  /// Conclui uma sessão aberta e registra os exercícios realizados.
  Future<WorkoutSession> completeWorkout(
    String sessionId, {
    required Duration duration,
    required List<PerformedExercise> exercises,
    String? note,
    DateTime? completedAt,
  });
}

/// Contrato para atividades esportivas manuais.
abstract interface class ActivityRepository {
  /// Lista atividades registradas, como corrida ou ciclismo.
  Future<List<ActivitySession>> getActivities();

  /// Adiciona uma atividade manual ao histórico.
  Future<ActivitySession> addActivity({
    required String categoryId,
    required DateTime performedAt,
    Duration? duration,
    double? distanceKm,
    int? intensity,
  });

  /// Calcula recordes pessoais a partir das atividades.
  Future<List<PersonalRecord>> getPersonalRecords();
}

/// Contrato para dados resumidos do dashboard.
abstract interface class DashboardRepository {
  /// Busca o treino sugerido para hoje, quando houver.
  Future<WorkoutPlan?> getTodayWorkout();

  /// Lista atributos musculares para o gráfico radar.
  Future<List<RadarAttribute>> getMuscleAttributes();

  /// Lista atributos esportivos para o gráfico radar.
  Future<List<RadarAttribute>> getCategoryAttributes();
}

/// Contrato para cálculo e leitura do ranking atual.
abstract interface class RankingRepository {
  /// Retorna o ranking atual da pessoa.
  Future<RankingCalculationResult> getCurrentRanking();
}

/// Contrato para conquistas.
abstract interface class AchievementRepository {
  /// Lista conquistas disponíveis ou desbloqueadas.
  Future<List<Achievement>> getAchievements();
}

/// Contrato para amizades e convites.
abstract interface class FriendRepository {
  /// Lista amigos confirmados.
  Future<List<FriendSummary>> getFriends();

  /// Lista convites enviados e recebidos.
  Future<List<FriendRequest>> getRequests();

  /// Envia um convite usando o código de outra pessoa.
  Future<FriendRequest> sendRequest(String code);

  /// Aceita ou recusa um convite existente.
  Future<void> respondToRequest(String requestId, FriendRequestStatus status);
}

/// Contrato para conversas sociais.
abstract interface class ChatRepository {
  /// Lista conversas disponíveis.
  Future<List<ChatConversation>> getConversations();
}
