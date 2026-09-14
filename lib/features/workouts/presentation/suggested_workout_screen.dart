import 'package:flutter/material.dart';

import '../../../app/theme/app_theme.dart';
import '../../../core/widgets/brand_widgets.dart';
import '../../../shared/data/local_api.dart';
import '../../../shared/models/models.dart';

class SuggestedWorkoutScreen extends StatefulWidget {
  const SuggestedWorkoutScreen({super.key});

  @override
  State<SuggestedWorkoutScreen> createState() => _SuggestedWorkoutScreenState();
}

class _SuggestedWorkoutScreenState extends State<SuggestedWorkoutScreen> {
  var _focus = TrainingCategory.strength;
  var _muscleGroup = 'upper_body';
  Map<String, dynamic>? _suggestion;
  String? _error;
  var _loading = false;

  Future<void> _loadSuggestion() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final suggestion = await LocalApi.instance.createWorkoutSuggestion(
        _categoryApiValue(_focus),
        muscleGroup: _focus == TrainingCategory.strength ? _muscleGroup : null,
      );
      if (!mounted) return;
      setState(() => _suggestion = suggestion);
    } on LocalApiException catch (error) {
      if (!mounted) return;
      setState(() => _error = error.message);
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('SUGERIR TREINO')),
      body: ListView(
        padding: const EdgeInsets.all(AppSpacing.lg),
        children: [
          const SectionHeading(
            'Qual é sua meta principal?',
            eyebrow: 'Recomendação temporária',
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: TrainingCategory.values
                .map(
                  (item) => ChoiceChip(
                    label: Text(item.label),
                    selected: _focus == item,
                    onSelected: (_) {
                      setState(() => _focus = item);
                    },
                  ),
                )
                .toList(),
          ),
          if (_focus == TrainingCategory.strength) ...[
            const SizedBox(height: 18),
            Text(
              'FOCO DA MUSCULAÇÃO',
              style: Theme.of(context).textTheme.labelLarge,
            ),
            const SizedBox(height: 10),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _muscleGroups
                  .map(
                    (item) => ChoiceChip(
                      label: Text(item.label),
                      selected: _muscleGroup == item.value,
                      onSelected: (_) =>
                          setState(() => _muscleGroup = item.value),
                    ),
                  )
                  .toList(),
            ),
          ],
          const SizedBox(height: 20),
          FilledButton.icon(
            onPressed: _loading ? null : _loadSuggestion,
            icon: const Icon(Icons.autorenew),
            label: const Text('SUGERIR NOVO TREINO'),
          ),
          const SizedBox(height: 24),
          if (_loading)
            const Center(child: CircularProgressIndicator())
          else if (_error != null)
            Card(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    Text(_error!),
                    const SizedBox(height: 12),
                    FilledButton(
                      onPressed: _loadSuggestion,
                      child: const Text('TENTAR NOVAMENTE'),
                    ),
                  ],
                ),
              ),
            )
          else if (_suggestion != null)
            _SuggestionCard(suggestion: _suggestion!),
          const SizedBox(height: 18),
          const Text(
            'Esta sugestão usa regras pré-definidas e não substitui avaliação profissional. A personalização por IA será adicionada por um serviço seguro quando houver chave de API.',
          ),
        ],
      ),
    );
  }
}

const _muscleGroups = [
  (value: 'chest', label: 'Peito'),
  (value: 'back', label: 'Costas'),
  (value: 'shoulders', label: 'Ombro'),
  (value: 'forearms', label: 'Antebraço'),
  (value: 'biceps', label: 'Bíceps'),
  (value: 'triceps', label: 'Tríceps'),
  (value: 'legs', label: 'Perna'),
  (value: 'upper_body', label: 'Superiores'),
  (value: 'lower_body', label: 'Inferiores'),
];

class _SuggestionCard extends StatelessWidget {
  const _SuggestionCard({required this.suggestion});
  final Map<String, dynamic> suggestion;

  @override
  Widget build(BuildContext context) => Card(
    color: AppColors.bone,
    child: Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            (suggestion['title'] as String).toUpperCase(),
            style: Theme.of(
              context,
            ).textTheme.headlineMedium?.copyWith(color: AppColors.voidBlack),
          ),
          const SizedBox(height: 8),
          Text(
            suggestion['rationale'] as String,
            style: const TextStyle(color: Color(0xFF454949)),
          ),
          const SizedBox(height: 20),
          ...(suggestion['items'] as List).map(
            (item) => Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Text(
                '• $item',
                style: const TextStyle(color: AppColors.voidBlack),
              ),
            ),
          ),
        ],
      ),
    ),
  );
}

String _categoryApiValue(TrainingCategory category) => switch (category) {
  TrainingCategory.strength => 'strength',
  TrainingCategory.running => 'running',
  TrainingCategory.cycling => 'cycling',
  TrainingCategory.swimming => 'swimming',
};
