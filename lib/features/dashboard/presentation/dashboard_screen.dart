import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/theme/app_theme.dart';
import '../../../core/widgets/brand_widgets.dart';
import '../../../shared/repositories/repositories.dart';

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final workout = ref.watch(todayWorkoutProvider);
    final ranking = ref.watch(rankingProvider);
    return CustomScrollView(
      slivers: [
        SliverAppBar(
          floating: true,
          backgroundColor: AppColors.voidBlack,
          title: const BrandMark(compact: true),
          actions: [
            IconButton(
              tooltip: 'Notificações',
              onPressed: () {},
              icon: const Icon(Icons.notifications_none),
            ),
          ],
        ),
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.lg,
            10,
            AppSpacing.lg,
            AppSpacing.xl,
          ),
          sliver: SliverList.list(
            children: [
              Text(
                'BOM DIA, ATLETA.',
                style: Theme.of(context).textTheme.displayMedium,
              ),
              const SizedBox(height: 6),
              const Text('Hoje é mais um ponto na sua linha de evolução.'),
              const SizedBox(height: 26),
              workout.when(
                loading: () => const _LoadingCard(height: 190),
                error: (_, _) => _ErrorCard(
                  onRetry: () => ref.invalidate(todayWorkoutProvider),
                ),
                data: (plan) => Card(
                  color: AppColors.bone,
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'TREINO DO DIA',
                          style: Theme.of(context).textTheme.labelSmall
                              ?.copyWith(color: AppColors.voidBlack),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          plan.name.toUpperCase(),
                          style: Theme.of(context).textTheme.headlineMedium
                              ?.copyWith(color: AppColors.voidBlack),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          '${plan.exerciseCount} exercícios · ${plan.estimatedMinutes} min · ${plan.groups.join(' + ')}',
                          style: const TextStyle(color: Color(0xFF454949)),
                        ),
                        const SizedBox(height: 22),
                        FilledButton.tonal(
                          onPressed: () => context.push('/workouts/${plan.id}'),
                          style: FilledButton.styleFrom(
                            backgroundColor: AppColors.voidBlack,
                            foregroundColor: AppColors.bone,
                          ),
                          child: const Text('INICIAR TREINO'),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 30),
              const SectionHeading('Seu progresso', eyebrow: 'Visão atual'),
              const SizedBox(height: 14),
              Card(
                child: Column(
                  children: [
                    const Padding(
                      padding: EdgeInsets.all(18),
                      child: Row(
                        children: [
                          Expanded(
                            child: Text(
                              'CONSISTÊNCIA\nANTES DE INTENSIDADE',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w900,
                                height: 1.05,
                              ),
                            ),
                          ),
                          Icon(
                            Icons.show_chart,
                            color: AppColors.frost,
                            size: 46,
                          ),
                        ],
                      ),
                    ),
                    const Row(
                      children: [
                        MetricTile(
                          value: '12',
                          label: 'dias em sequência',
                          accent: true,
                        ),
                        MetricTile(value: '32', label: 'treinos'),
                        MetricTile(value: '+8%', label: 'evolução'),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 30),
              SectionHeading(
                'Ranking atual',
                eyebrow: 'Comparativo',
                trailing: TextButton(
                  onPressed: () => context.go('/ranking'),
                  child: const Text('VER RANKING'),
                ),
              ),
              const SizedBox(height: 14),
              ranking.when(
                loading: () => const _LoadingCard(height: 120),
                error: (_, _) =>
                    _ErrorCard(onRetry: () => ref.invalidate(rankingProvider)),
                data: (result) => Card(
                  child: Padding(
                    padding: const EdgeInsets.all(18),
                    child: Row(
                      children: [
                        Text(
                          '#84',
                          style: Theme.of(context).textTheme.displayMedium,
                        ),
                        const SizedBox(width: 18),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'POSIÇÃO GLOBAL',
                                style: TextStyle(fontWeight: FontWeight.w800),
                              ),
                              const SizedBox(height: 5),
                              Text(
                                '${result.totalScore?.toStringAsFixed(1)} pontos · ${result.rankedCategories.first.category.name}',
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 30),
              const SectionHeading('Explorar', eyebrow: 'Detalhes'),
              const SizedBox(height: 14),
              ...[
                (
                  'AGENDA DE TREINOS',
                  'Organize sua semana',
                  Icons.calendar_today_outlined,
                ),
                ('HISTÓRICO DE EVOLUÇÃO', 'Compare períodos', Icons.timeline),
                (
                  'HISTÓRICO DE ATIVIDADES',
                  'Revise seus registros',
                  Icons.history,
                ),
                ('ATRIBUTOS', 'Veja seus gráficos', Icons.radar),
              ].map(
                (item) => Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Card(
                    child: ListTile(
                      minTileHeight: 68,
                      leading: Icon(item.$3),
                      title: Text(
                        item.$1,
                        style: const TextStyle(fontWeight: FontWeight.w800),
                      ),
                      subtitle: Text(item.$2),
                      trailing: const Icon(Icons.arrow_forward),
                      onTap: () => item.$1 == 'ATRIBUTOS'
                          ? context.go('/profile')
                          : item.$1 == 'HISTÓRICO DE ATIVIDADES'
                          ? context.push('/activities')
                          : item.$1 == 'AGENDA DE TREINOS'
                          ? context.push('/workouts')
                          : _notice(
                              context,
                              '${item.$1} está em desenvolvimento.',
                            ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

void _notice(BuildContext context, String text) =>
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(text)));

class _LoadingCard extends StatelessWidget {
  const _LoadingCard({required this.height});
  final double height;
  @override
  Widget build(BuildContext context) => Semantics(
    label: 'Carregando',
    child: Container(
      height: height,
      color: AppColors.carbon,
      alignment: Alignment.center,
      child: const CircularProgressIndicator(),
    ),
  );
}

class _ErrorCard extends StatelessWidget {
  const _ErrorCard({required this.onRetry});
  final VoidCallback onRetry;
  @override
  Widget build(BuildContext context) => Card(
    child: Padding(
      padding: const EdgeInsets.all(18),
      child: Column(
        children: [
          const Text('Não foi possível carregar os dados.'),
          TextButton(onPressed: onRetry, child: const Text('TENTAR NOVAMENTE')),
        ],
      ),
    ),
  );
}
