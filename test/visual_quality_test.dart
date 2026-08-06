import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:limit_breaker/app/app.dart';
import 'package:limit_breaker/features/shell/presentation/main_shell.dart';
import 'package:limit_breaker/shared/repositories/repositories.dart';

class _CompletedOnboarding implements OnboardingRepository {
  @override
  Future<void> complete() async {}

  @override
  Future<bool> isComplete() async => true;
}

void main() {
  testWidgets('Dashboard mobile mantém referência visual', (tester) async {
    await tester.binding.setSurfaceSize(const Size(390, 844));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          onboardingRepositoryProvider.overrideWithValue(
            _CompletedOnboarding(),
          ),
        ],
        child: const LimitBreakerApp(),
      ),
    );
    await tester.tap(find.byType(GestureDetector).first);
    await tester.pumpAndSettle();
    await expectLater(
      find.byType(MainShell),
      matchesGoldenFile('goldens/dashboard.png'),
    );
  });
}
