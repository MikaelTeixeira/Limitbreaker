import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:limit_breaker/app/app.dart';
import 'package:limit_breaker/shared/repositories/repositories.dart';

class _MemoryOnboardingRepository implements OnboardingRepository {
  _MemoryOnboardingRepository(this.done);
  bool done;
  @override
  Future<void> complete() async => done = true;
  @override
  Future<bool> isComplete() async => done;
}

void main() {
  testWidgets('primeiro acesso abre boas-vindas após toque', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          onboardingRepositoryProvider.overrideWithValue(
            _MemoryOnboardingRepository(false),
          ),
        ],
        child: const LimitBreakerApp(),
      ),
    );
    expect(find.text('SUPERE.\nREGISTRE.\nEVOLUA.'), findsOneWidget);
    await tester.tap(find.byType(GestureDetector).first);
    await tester.pumpAndSettle();
    expect(find.text('BEM-VINDO AO\nLIMIT BREAKER'), findsOneWidget);
    expect(find.text('COMEÇAR'), findsOneWidget);
  });

  testWidgets('usuário concluído entra no Dashboard e navega pelo rodapé', (
    tester,
  ) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          onboardingRepositoryProvider.overrideWithValue(
            _MemoryOnboardingRepository(true),
          ),
        ],
        child: const LimitBreakerApp(),
      ),
    );
    await tester.tap(find.byType(GestureDetector).first);
    await tester.pumpAndSettle();
    expect(find.text('BOM DIA, ATLETA.'), findsOneWidget);
    await tester.tap(find.text('Ranking').last);
    await tester.pumpAndSettle();
    expect(find.text('BASE DO CÁLCULO'), findsOneWidget);
    expect(find.byType(NavigationBar), findsOneWidget);
  });
}
