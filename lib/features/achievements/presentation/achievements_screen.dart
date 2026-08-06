import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/theme/app_theme.dart';
import '../../../core/widgets/brand_widgets.dart';
import '../../../shared/repositories/repositories.dart';

class AchievementsScreen extends ConsumerWidget {
  const AchievementsScreen({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final achievements = ref.watch(achievementsProvider).value ?? const [];
    const icons = [
      Icons.calendar_view_week,
      Icons.self_improvement,
      Icons.trending_up,
      Icons.repeat,
    ];
    return Scaffold(
      appBar: AppBar(title: const Text('CONQUISTAS')),
      body: ListView(
        padding: const EdgeInsets.all(AppSpacing.lg),
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  '${achievements.length}'.padLeft(2, '0'),
                  style: Theme.of(context).textTheme.displayLarge,
                ),
              ),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      '12 PONTOS',
                      style: TextStyle(fontWeight: FontWeight.w900),
                    ),
                    Text(
                      'Somente conquistas oficiais',
                      textAlign: TextAlign.end,
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 28),
          const SectionHeading('Desbloqueadas', eyebrow: 'Progresso oficial'),
          const SizedBox(height: 12),
          GridView.count(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisCount: 2,
            mainAxisSpacing: 8,
            crossAxisSpacing: 8,
            childAspectRatio: 1.12,
            children: List.generate(
              achievements.length,
              (index) => _Achievement(
                icon: icons[index % icons.length],
                title: achievements[index].title,
                official: achievements[index].influencesRanking,
              ),
            ),
          ),
          const SizedBox(height: 28),
          const SectionHeading(
            'Checkpoints pessoais',
            eyebrow: 'Não alteram o ranking',
          ),
          const SizedBox(height: 12),
          const Card(
            child: ListTile(
              leading: Icon(Icons.flag_outlined),
              title: Text('Correr 10 km'),
              subtitle: Text('Meta criada por você · 52%'),
              trailing: Icon(Icons.arrow_forward),
            ),
          ),
          const Card(
            child: ListTile(
              leading: Icon(Icons.add),
              title: Text('CRIAR CHECKPOINT'),
              subtitle: Text('Defina uma meta pessoal'),
            ),
          ),
        ],
      ),
    );
  }
}

class _Achievement extends StatelessWidget {
  const _Achievement({
    required this.icon,
    required this.title,
    required this.official,
  });
  final IconData icon;
  final String title;
  final bool official;
  @override
  Widget build(BuildContext context) => Card(
    child: Padding(
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: AppColors.frost),
          const Spacer(),
          Text(title, style: const TextStyle(fontWeight: FontWeight.w900)),
          const SizedBox(height: 4),
          Text(
            official ? 'OFICIAL · +3 PTS' : 'PESSOAL',
            style: Theme.of(context).textTheme.labelSmall,
          ),
        ],
      ),
    ),
  );
}
