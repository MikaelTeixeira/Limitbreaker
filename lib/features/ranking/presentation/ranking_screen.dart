import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/theme/app_theme.dart';
import '../../../core/widgets/brand_widgets.dart';
import '../../../features/ranking/domain/ranking_calculator.dart';
import '../../../shared/repositories/repositories.dart';

class RankingScreen extends ConsumerStatefulWidget {
  const RankingScreen({super.key});

  @override
  ConsumerState<RankingScreen> createState() => _RankingScreenState();
}

class _RankingScreenState extends ConsumerState<RankingScreen> {
  var friends = false;

  @override
  Widget build(BuildContext context) {
    final ranking = ref.watch(rankingProvider);
    return Scaffold(
      appBar: AppBar(title: const Text('RANKING')),
      body: ranking.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (_, _) => Center(
          child: FilledButton(
            onPressed: () => ref.invalidate(rankingProvider),
            child: const Text('TENTAR NOVAMENTE'),
          ),
        ),
        data: (result) => ListView(
          padding: const EdgeInsets.all(AppSpacing.lg),
          children: [
            SegmentedButton<bool>(
              segments: const [
                ButtonSegment(value: false, label: Text('GLOBAL')),
                ButtonSegment(value: true, label: Text('AMIGOS')),
              ],
              selected: {friends},
              onSelectionChanged: (value) =>
                  setState(() => friends = value.first),
            ),
            const SizedBox(height: 26),
            Text(
              friends ? '—' : '#1',
              style: Theme.of(context).textTheme.displayLarge,
            ),
            Text(
              friends ? 'SEM AMIGOS ADICIONADOS' : 'POSIÇÃO GLOBAL INICIAL',
              style: Theme.of(context).textTheme.labelSmall,
            ),
            const SizedBox(height: 20),
            _RankingSummary(result: result, friends: friends),
            if (!friends && result.rankedCategories.isNotEmpty) ...[
              const SizedBox(height: 28),
              const SectionHeading(
                'Base do cálculo',
                eyebrow: 'Top 3 · pesos 75 / 15 / 10',
              ),
              const SizedBox(height: 12),
              ...List.generate(result.rankedCategories.length, (index) {
                final item = result.rankedCategories[index];
                return Card(
                  child: ListTile(
                    leading: CircleAvatar(child: Text('${index + 1}')),
                    title: Text(item.category.name),
                    subtitle: Text(
                      'Peso ${(result.appliedWeights[index] * 100).round()}%',
                    ),
                    trailing: Text(item.normalizedScore.toStringAsFixed(0)),
                  ),
                );
              }),
            ],
            const SizedBox(height: 28),
            const SectionHeading('Classificação', eyebrow: 'Dados reais'),
            const SizedBox(height: 12),
            if (friends)
              const Card(
                child: ListTile(
                  leading: Icon(Icons.group_outlined),
                  title: Text('Nenhum amigo adicionado'),
                  subtitle: Text('Envie um convite para comparar posições.'),
                ),
              )
            else
              const Card(
                child: ListTile(
                  leading: Text('01'),
                  title: Text('Você'),
                  subtitle: Text('Ainda sem pontuação registrada'),
                  trailing: Text('—'),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _RankingSummary extends StatelessWidget {
  const _RankingSummary({required this.result, required this.friends});

  final RankingCalculationResult result;
  final bool friends;

  @override
  Widget build(BuildContext context) => Card(
    child: Padding(
      padding: const EdgeInsets.all(20),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  friends
                      ? 'CONVIDE PARA COMPARAR'
                      : result.status == RankingCalculationStatus.unavailable
                      ? 'SEM PONTUAÇÃO AINDA'
                      : 'RANKING PROVISÓRIO',
                  style: const TextStyle(fontWeight: FontWeight.w900),
                ),
                const SizedBox(height: 6),
                Text(
                  friends
                      ? 'O ranking entre amigos aparece após o primeiro convite aceito.'
                      : result.totalScore == null
                      ? 'Registre atividades em três modalidades para calcular sua pontuação.'
                      : '${result.totalScore!.toStringAsFixed(1)} pontos normalizados',
                ),
              ],
            ),
          ),
          const Icon(Icons.bolt, color: AppColors.frost, size: 42),
        ],
      ),
    ),
  );
}
