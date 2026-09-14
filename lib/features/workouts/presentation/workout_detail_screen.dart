import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/theme/app_theme.dart';
import '../../../core/widgets/brand_widgets.dart';
import '../../../shared/data/local_api.dart';
import '../../../shared/repositories/repositories.dart';

/// Exibe uma sessão persistida e permite sua exclusão segura.
class WorkoutDetailScreen extends ConsumerWidget {
  const WorkoutDetailScreen({super.key, required this.workoutId});

  final String workoutId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final detail = ref.watch(workoutDetailProvider(workoutId));
    return Scaffold(
      appBar: AppBar(
        title: const Text('DETALHE DO TREINO'),
        actions: [
          IconButton(
            tooltip: 'Excluir treino',
            onPressed: detail.value == null
                ? null
                : () => _confirmDelete(context, ref),
            icon: const Icon(Icons.delete_outline),
          ),
        ],
      ),
      body: detail.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => Center(
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text('Não foi possível carregar este treino.'),
                const SizedBox(height: 12),
                OutlinedButton(
                  onPressed: () =>
                      ref.invalidate(workoutDetailProvider(workoutId)),
                  child: const Text('TENTAR NOVAMENTE'),
                ),
              ],
            ),
          ),
        ),
        data: (item) => _WorkoutContent(item: item),
      ),
    );
  }

  Future<void> _confirmDelete(BuildContext context, WidgetRef ref) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Excluir treino?'),
        content: const Text(
          'O treino e suas séries serão removidos permanentemente.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('CANCELAR'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text('EXCLUIR'),
          ),
        ],
      ),
    );
    if (confirmed != true || !context.mounted) return;
    try {
      await LocalApi.instance.deleteWorkout(workoutId);
      ref.invalidate(workoutSessionsProvider);
      ref.invalidate(activitiesProvider);
      ref.invalidate(personalRecordsProvider);
      if (context.mounted) context.pop();
    } on LocalApiException catch (error) {
      if (context.mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(error.message)));
      }
    }
  }
}

class _WorkoutContent extends StatelessWidget {
  const _WorkoutContent({required this.item});

  final Map<String, dynamic> item;

  @override
  Widget build(BuildContext context) {
    final category = item['category'].toString();
    final exercises = (item['exercises'] as List? ?? const []);
    final distance = (item['distance_meters'] as num?)?.toDouble();
    return ListView(
      padding: const EdgeInsets.all(AppSpacing.lg),
      children: [
        SectionHeading(_categoryLabel(category), eyebrow: 'Treino concluído'),
        const SizedBox(height: 12),
        Card(
          child: ListTile(
            leading: const Icon(Icons.schedule_outlined),
            title: Text(
              '${(item['duration_seconds'] as num).toInt() ~/ 60} min',
            ),
            subtitle: Text(_date(item['performed_at'].toString())),
            trailing: distance == null
                ? null
                : Text(
                    category == 'swimming'
                        ? '${distance.toStringAsFixed(0)} m'
                        : '${(distance / 1000).toStringAsFixed(2)} km',
                  ),
          ),
        ),
        if (exercises.isNotEmpty) ...[
          const SizedBox(height: 24),
          SectionHeading(
            'Exercícios',
            eyebrow: '${exercises.length} registros',
          ),
          const SizedBox(height: 10),
          ...exercises.map((raw) {
            final exercise = Map<String, dynamic>.from(raw as Map);
            final sets = exercise['sets'] as List? ?? const [];
            return Card(
              child: ExpansionTile(
                title: Text(exercise['name'].toString()),
                subtitle: Text(exercise['muscle_group'].toString()),
                children: sets.map((rawSet) {
                  final set = Map<String, dynamic>.from(rawSet as Map);
                  return ListTile(
                    title: Text('Série ${set['set_number']}'),
                    trailing: Text(
                      '${set['repetitions']} rep · ${set['load_kg']} kg',
                    ),
                  );
                }).toList(),
              ),
            );
          }),
        ],
      ],
    );
  }

  String _categoryLabel(String value) => switch (value) {
    'strength' => 'Musculação',
    'running' => 'Corrida',
    'cycling' => 'Ciclismo',
    'swimming' => 'Natação',
    _ => 'Treino',
  };

  String _date(String value) {
    final date = DateTime.tryParse(value)?.toLocal();
    if (date == null) return value;
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
  }
}
