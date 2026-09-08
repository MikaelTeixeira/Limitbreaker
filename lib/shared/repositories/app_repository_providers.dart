import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../features/ranking/domain/ranking_calculator.dart';
import '../data/local_api.dart';
import '../models/models.dart';
import 'local_demo_repository.dart';
import 'local_onboarding_repository.dart';
import 'repository_contracts.dart';

/// Provider da persistência local do onboarding.
final onboardingRepositoryProvider = Provider<OnboardingRepository>(
  (ref) => LocalOnboardingRepository(),
);

/// Provider da implementação local usada enquanto o backend evolui.
final appRepositoryProvider = Provider<LocalAppRepository>(
  (ref) => LocalAppRepository(),
);

/// Provider do contrato de treinos.
final workoutRepositoryProvider = Provider<WorkoutRepository>(
  (ref) => ref.watch(appRepositoryProvider),
);

/// Estado assíncrono que indica se o onboarding foi concluído.
final onboardingCompleteProvider = FutureProvider<bool>(
  (ref) => ref.watch(onboardingRepositoryProvider).isComplete(),
);

/// Primeiro plano disponível para a tela inicial.
final todayWorkoutProvider = FutureProvider<WorkoutPlan?>(
  (ref) => ref
      .watch(workoutRepositoryProvider)
      .getPlans()
      .then((plans) => plans.isEmpty ? null : plans.first),
);

/// Lista de planos de treino disponíveis.
final workoutPlansProvider = FutureProvider<List<WorkoutPlan>>(
  (ref) => ref.watch(workoutRepositoryProvider).getPlans(),
);

/// Lista treinos gravados na API local autenticada.
final workoutSessionsProvider = FutureProvider<List<WorkoutSession>>((
  ref,
) async {
  final items = await LocalApi.instance.listWorkouts();
  return items
      .map(
        (item) => WorkoutSession(
          id: item['id'].toString(),
          planId: item['category'].toString(),
          performedAt: DateTime.parse(item['performed_at'].toString()),
          completedAt: DateTime.parse(item['performed_at'].toString()),
          duration: Duration(
            seconds: (item['duration_seconds'] as num?)?.toInt() ?? 0,
          ),
        ),
      )
      .toList();
});

/// Lista atividades esportivas em memória.
final activitiesProvider = FutureProvider<List<ActivitySession>>(
  (ref) => ref.watch(appRepositoryProvider).getActivities(),
);

/// Lista recordes pessoais calculados localmente.
final personalRecordsProvider = FutureProvider<List<PersonalRecord>>(
  (ref) => ref.watch(appRepositoryProvider).getPersonalRecords(),
);

/// Atributos musculares usados no dashboard.
final muscleAttributesProvider = FutureProvider<List<RadarAttribute>>(
  (ref) => ref.watch(appRepositoryProvider).getMuscleAttributes(),
);

/// Atributos esportivos usados no dashboard.
final categoryAttributesProvider = FutureProvider<List<RadarAttribute>>(
  (ref) => ref.watch(appRepositoryProvider).getCategoryAttributes(),
);

/// Resultado atual do ranking.
final rankingProvider = FutureProvider<RankingCalculationResult>(
  (ref) => ref.watch(appRepositoryProvider).getCurrentRanking(),
);

/// Lista amigos confirmados.
final friendsProvider = FutureProvider<List<FriendSummary>>(
  (ref) => ref.watch(appRepositoryProvider).getFriends(),
);

/// Lista convites de amizade.
final friendRequestsProvider = FutureProvider<List<FriendRequest>>(
  (ref) => ref.watch(appRepositoryProvider).getRequests(),
);

/// Lista conquistas exibidas no aplicativo.
final achievementsProvider = FutureProvider<List<Achievement>>(
  (ref) => ref.watch(appRepositoryProvider).getAchievements(),
);
