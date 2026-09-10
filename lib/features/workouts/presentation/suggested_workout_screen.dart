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
  Map<String, dynamic>? _suggestion;
  String? _error;
  var _loading = true;

  @override
  void initState() {
    super.initState();
    _loadSuggestion();
  }

  Future<void> _loadSuggestion() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final suggestion = await LocalApi.instance.createWorkoutSuggestion(
        _categoryApiValue(_focus),
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
                      _loadSuggestion();
                    },
                  ),
                )
                .toList(),
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
          else
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
