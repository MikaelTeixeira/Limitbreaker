import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/theme/app_theme.dart';
import '../../../core/widgets/brand_widgets.dart';
import '../../../shared/repositories/repositories.dart';

class ActivitiesScreen extends ConsumerStatefulWidget {
  const ActivitiesScreen({super.key});
  @override
  ConsumerState<ActivitiesScreen> createState() => _ActivitiesScreenState();
}

class _ActivitiesScreenState extends ConsumerState<ActivitiesScreen> {
  final _distance = TextEditingController();
  final _duration = TextEditingController();
  final _intensity = TextEditingController(text: '5');
  String _category = 'running';
  @override
  void dispose() {
    _distance.dispose();
    _duration.dispose();
    _intensity.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final distance = double.tryParse(_distance.text.replaceAll(',', '.'));
    final minutes = int.tryParse(_duration.text);
    final intensity = int.tryParse(_intensity.text);
    if (minutes == null ||
        minutes <= 0 ||
        (distance != null && distance < 0) ||
        (intensity != null && (intensity < 1 || intensity > 10))) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Informe duração válida e intensidade de 1 a 10.'),
        ),
      );
      return;
    }
    await ref
        .read(appRepositoryProvider)
        .addActivity(
          categoryId: _category,
          performedAt: DateTime.now(),
          duration: Duration(minutes: minutes),
          distanceKm: distance,
          intensity: intensity,
        );
    ref.invalidate(activitiesProvider);
    ref.invalidate(personalRecordsProvider);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Atividade salva localmente.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final activities = ref.watch(activitiesProvider);
    final records = ref.watch(personalRecordsProvider);
    return Scaffold(
      appBar: AppBar(title: const Text('ATIVIDADES')),
      body: ListView(
        padding: const EdgeInsets.all(AppSpacing.lg),
        children: [
          const SectionHeading('Registrar atividade', eyebrow: 'Dados locais'),
          const SizedBox(height: 12),
          DropdownButtonFormField<String>(
            initialValue: _category,
            items: const [
              DropdownMenuItem(value: 'running', child: Text('Corrida')),
              DropdownMenuItem(value: 'cycling', child: Text('Ciclismo')),
              DropdownMenuItem(value: 'mobility', child: Text('Mobilidade')),
            ],
            onChanged: (value) => setState(() => _category = value!),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _duration,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(labelText: 'Duração (min)'),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: TextField(
                  controller: _distance,
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  decoration: const InputDecoration(
                    labelText: 'Distância (km)',
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          TextField(
            controller: _intensity,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(labelText: 'Intensidade (1–10)'),
          ),
          const SizedBox(height: 12),
          FilledButton(onPressed: _save, child: const Text('SALVAR ATIVIDADE')),
          const SizedBox(height: 28),
          const SectionHeading(
            'Recordes pessoais',
            eyebrow: 'Atividades registradas',
          ),
          const SizedBox(height: 10),
          ...records.when(
            loading: () => [const CircularProgressIndicator()],
            error: (_, _) => [
              const Text('Não foi possível carregar recordes.'),
            ],
            data: (items) => items.isEmpty
                ? [
                    const Text(
                      'Registre uma corrida para formar seu primeiro recorde.',
                    ),
                  ]
                : items
                      .map(
                        (record) => Card(
                          child: ListTile(
                            leading: const Icon(
                              Icons.emoji_events_outlined,
                              color: AppColors.frost,
                            ),
                            title: Text(record.label),
                            trailing: Text(
                              '${record.value.toStringAsFixed(1)} km',
                            ),
                          ),
                        ),
                      )
                      .toList(),
          ),
          const SizedBox(height: 28),
          const SectionHeading(
            'Histórico de atividades',
            eyebrow: 'Mais recente primeiro',
          ),
          const SizedBox(height: 10),
          ...activities.when(
            loading: () => [const CircularProgressIndicator()],
            error: (_, _) => [
              const Text('Não foi possível carregar o histórico.'),
            ],
            data: (items) => items.isEmpty
                ? [const Text('Nenhuma atividade registrada.')]
                : items
                      .map(
                        (item) => Card(
                          child: ListTile(
                            leading: const Icon(Icons.directions_run),
                            title: Text(item.categoryId.toUpperCase()),
                            subtitle: Text(
                              '${item.duration?.inMinutes ?? 0} min · intensidade ${item.intensity ?? '-'}',
                            ),
                            trailing: Text(
                              item.distanceKm == null
                                  ? ''
                                  : '${item.distanceKm!.toStringAsFixed(1)} km',
                            ),
                          ),
                        ),
                      )
                      .toList(),
          ),
        ],
      ),
    );
  }
}
