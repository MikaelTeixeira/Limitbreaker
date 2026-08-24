import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../features/auth/presentation/access_screens.dart';
import '../../features/admin/presentation/admin_screen.dart';
import '../../features/activities/presentation/activities_screen.dart';
import '../../features/dashboard/presentation/dashboard_screen.dart';
import '../../features/exercises/presentation/exercises_screen.dart';
import '../../features/friends/presentation/friends_screen.dart';
import '../../features/onboarding/presentation/entry_screens.dart';
import '../../features/onboarding/presentation/onboarding_screen.dart';
import '../../features/profile/presentation/profile_screen.dart';
import '../../features/ranking/presentation/ranking_screen.dart';
import '../../features/shell/presentation/main_shell.dart';
import '../../features/workouts/presentation/workouts_screens.dart';
import '../../features/workouts/presentation/workout_registration_screen.dart';
import '../../features/workouts/presentation/suggested_workout_screen.dart';
import '../../shared/models/models.dart';

final appRouterProvider = Provider<GoRouter>(
  (ref) => GoRouter(
    initialLocation: '/',
    routes: [
      GoRoute(path: '/', builder: (_, _) => const SplashScreen()),
      GoRoute(path: '/welcome', builder: (_, _) => const WelcomeScreen()),
      GoRoute(path: '/login', builder: (_, _) => const LoginScreen()),
      GoRoute(path: '/admin', builder: (_, _) => const AdminScreen()),
      GoRoute(path: '/register', builder: (_, _) => const OnboardingScreen()),
      GoRoute(path: '/onboarding', builder: (_, _) => const OnboardingScreen()),
      GoRoute(
        path: '/workouts',
        builder: (_, _) => const MainShell(index: 3, child: WorkoutsScreen()),
      ),
      GoRoute(
        path: '/workouts/register',
        builder: (_, state) => WorkoutRegistrationScreen(
          initialCategory: state.uri.queryParameters['category'] == 'strength'
              ? TrainingCategory.strength
              : null,
        ),
      ),
      GoRoute(
        path: '/suggest-workout',
        builder: (_, _) => const SuggestedWorkoutScreen(),
      ),
      GoRoute(path: '/activities', builder: (_, _) => const ActivitiesScreen()),
      GoRoute(path: '/exercises', builder: (_, _) => const ExercisesScreen()),
      GoRoute(
        path: '/workouts/:planId',
        builder: (_, state) =>
            WorkoutSessionScreen(planId: state.pathParameters['planId']!),
      ),
      GoRoute(
        path: '/home',
        builder: (_, _) => const MainShell(index: 0, child: DashboardScreen()),
      ),
      GoRoute(
        path: '/ranking',
        builder: (_, _) => const MainShell(index: 1, child: RankingScreen()),
      ),
      GoRoute(
        path: '/friends',
        builder: (_, _) => const MainShell(index: 2, child: FriendsScreen()),
      ),
      GoRoute(
        path: '/profile',
        builder: (_, _) => const MainShell(index: 4, child: ProfileScreen()),
      ),
    ],
  ),
);
