import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/theme/app_theme.dart';
import '../../../core/widgets/brand_widgets.dart';
import '../../../shared/repositories/repositories.dart';

class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});
  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  bool _leaving = false;
  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 260),
      value: 1,
    );
  }

  Future<void> _enter() async {
    if (_leaving) return;
    _leaving = true;
    await _controller.reverse();
    if (!mounted) return;
    final complete = await ref.read(onboardingRepositoryProvider).isComplete();
    if (mounted) context.go(complete ? '/home' : '/welcome');
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    body: GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: _enter,
      child: FadeTransition(
        opacity: _controller,
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const BrandMark(),
                const SizedBox(height: 12),
                const Expanded(child: FocusSilhouette()),
                const SizedBox(height: 12),
                Text(
                  'SUPERE.\nREGISTRE.\nEVOLUA.',
                  style: Theme.of(context).textTheme.displayLarge,
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Text(
                      'TOQUE PARA ENTRAR',
                      style: Theme.of(context).textTheme.labelSmall,
                    ),
                    const Spacer(),
                    const Icon(Icons.arrow_forward, size: 18),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    ),
  );
}

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});
  @override
  Widget build(BuildContext context) => Scaffold(
    body: SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const BrandMark(compact: true),
            const SizedBox(height: 24),
            const Expanded(child: FocusSilhouette()),
            Text(
              'BEM-VINDO AO\nLIMIT BREAKER',
              style: Theme.of(context).textTheme.displayMedium,
            ),
            const SizedBox(height: 12),
            const Text(
              'Sua evolução começa com um registro honesto. Defina seu ponto de partida e avance no seu ritmo.',
            ),
            const SizedBox(height: 24),
            FilledButton(
              onPressed: () => context.go('/onboarding'),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [Text('COMEÇAR'), Icon(Icons.arrow_forward)],
              ),
            ),
          ],
        ),
      ),
    ),
  );
}
