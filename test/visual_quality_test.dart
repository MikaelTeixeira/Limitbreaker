import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:limit_breaker/features/dashboard/presentation/dashboard_screen.dart';
import 'package:limit_breaker/features/shell/presentation/main_shell.dart';
import 'package:limit_breaker/app/theme/app_theme.dart';

void main() {
  testWidgets('Dashboard mobile mantém referência visual', (tester) async {
    await tester.binding.setSurfaceSize(const Size(390, 844));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    await tester.pumpWidget(
      ProviderScope(
        child: MaterialApp(
          theme: AppTheme.dark,
          home: const MainShell(index: 0, child: DashboardScreen()),
        ),
      ),
    );
    await tester.pumpAndSettle();
    await expectLater(
      find.byType(MainShell),
      matchesGoldenFile('goldens/dashboard.png'),
    );
  });
}
