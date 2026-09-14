import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/theme/app_theme.dart';
import '../../../core/widgets/brand_widgets.dart';
import '../../../shared/data/local_api.dart';
import '../../../shared/models/models.dart';
import '../../../shared/repositories/repositories.dart';
import '../domain/pace_calculator.dart';

class ActivitiesScreen extends ConsumerStatefulWidget {
  const ActivitiesScreen({super.key});
  @override
  ConsumerState<ActivitiesScreen> createState() => _ActivitiesScreenState();
}

class _ActivitiesScreenState extends ConsumerState<ActivitiesScreen> {
  final _distance = TextEditingController();
  final _duration = TextEditingController();
  String _category = 'running';
  var _saving = false;
  @override
  void dispose() {
    _distance.dispose();
    _duration.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final distance = double.tryParse(_distance.text.replaceAll(',', '.'));
    final distanceKm = _category == 'swimming' && distance != null
        ? distance / 1000
        : distance;
    final minutes = int.tryParse(_duration.text);
    if (minutes == null ||
        minutes <= 0 ||
        distanceKm == null ||
        distanceKm <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Informe duração e distância válidas.')),
      );
      return;
    }
    setState(() => _saving = true);
    try {
      await LocalApi.instance.createWorkout({
        'category': _category,
        'durationSeconds': minutes * 60,
        'distanceMeters': distanceKm * 1000,
      });
    } on LocalApiException catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(error.message)));
      }
      return;
    } finally {
      if (mounted) setState(() => _saving = false);
    }
    ref.invalidate(activitiesProvider);
    ref.invalidate(personalRecordsProvider);
    if (mounted) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Atividade salva.')));
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
          const SectionHeading('Registrar atividade', eyebrow: 'Seu histórico'),
          const SizedBox(height: 12),
          DropdownButtonFormField<String>(
            initialValue: _category,
            items: const [
              DropdownMenuItem(value: 'running', child: Text('Corrida')),
              DropdownMenuItem(value: 'cycling', child: Text('Ciclismo')),
              DropdownMenuItem(value: 'swimming', child: Text('Natação')),
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
                  decoration: InputDecoration(
                    labelText: _category == 'swimming'
                        ? 'Distância nadada (m)'
                        : 'Distância (km)',
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          FilledButton(
            onPressed: _saving ? null : _save,
            child: Text(_saving ? 'SALVANDO…' : 'SALVAR ATIVIDADE'),
          ),
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
                            trailing: Text(_recordValue(record)),
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
                              '${item.duration?.inMinutes ?? 0} min${_pace(item) == null ? '' : ' · pace ${_pace(item)}'}',
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

  String? _pace(ActivitySession item) => PaceCalculator.format(
    categoryId: item.categoryId,
    duration: item.duration,
    distanceKm: item.distanceKm,
  );

  String _recordValue(PersonalRecord record) {
    if (record.unit == 's/km' || record.unit == 's/100m') {
      final minutes = record.value ~/ 60;
      final seconds = (record.value % 60).round().toString().padLeft(2, '0');
      return '$minutes:$seconds ${record.unit.substring(1)}';
    }
    return '${record.value.toStringAsFixed(1)} ${record.unit}';
  }
}
