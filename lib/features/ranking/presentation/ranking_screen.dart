import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/theme/app_theme.dart';
import '../../../core/widgets/brand_widgets.dart';
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
              friends ? '#03' : '#84',
              style: Theme.of(context).textTheme.displayLarge,
            ),
            Text(
              friends ? 'ENTRE AMIGOS' : 'POSIÇÃO GLOBAL',
              style: Theme.of(context).textTheme.labelSmall,
            ),
            const SizedBox(height: 20),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'RANKING PROVISÓRIO',
                            style: TextStyle(fontWeight: FontWeight.w900),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            '${result.totalScore?.toStringAsFixed(1)} pontos normalizados',
                          ),
                        ],
                      ),
                    ),
                    const Icon(Icons.bolt, color: AppColors.frost, size: 42),
                  ],
                ),
              ),
            ),
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
                  leading: CircleAvatar(
                    backgroundColor: index == 0
                        ? AppColors.bone
                        : AppColors.graphite,
                    foregroundColor: index == 0
                        ? AppColors.voidBlack
                        : AppColors.bone,
                    child: Text('${index + 1}'),
                  ),
                  title: Text(
                    item.category.name,
                    style: const TextStyle(fontWeight: FontWeight.w800),
                  ),
                  subtitle: Text(
                    'Peso ${(result.appliedWeights[index] * 100).round()}%',
                  ),
                  trailing: Text(
                    item.normalizedScore.toStringAsFixed(0),
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                ),
              );
            }),
            const SizedBox(height: 28),
            const SectionHeading('Classificação', eyebrow: 'Dados simulados'),
            const SizedBox(height: 12),
            ..._people(friends).asMap().entries.map(
              (entry) => ListTile(
                contentPadding: EdgeInsets.zero,
                leading: Text(
                  '${entry.key + 1}'.padLeft(2, '0'),
                  style: Theme.of(context).textTheme.labelSmall,
                ),
                title: Text(entry.value.$1),
                trailing: Text(entry.value.$2),
                tileColor: entry.value.$1 == 'Você' ? AppColors.bone : null,
                textColor: entry.value.$1 == 'Você'
                    ? AppColors.voidBlack
                    : null,
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<(String, String)> _people(bool onlyFriends) => onlyFriends
      ? [
          ('Lívia', '82.4'),
          ('Rafael', '77.8'),
          ('Você', '80.8'),
          ('Caio', '68.3'),
        ]
      : [
          ('Joana Lima', '96.2'),
          ('Carlos Mendes', '94.8'),
          ('Ana Costa', '92.1'),
          ('Mateus Rocha', '91.5'),
          ('Você', '80.8'),
        ];
}
