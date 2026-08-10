import 'package:flutter/material.dart';

import '../../../app/theme/app_theme.dart';
import '../../../core/widgets/brand_widgets.dart';
import '../../../shared/models/models.dart';

class SuggestedWorkoutScreen extends StatefulWidget {
  const SuggestedWorkoutScreen({super.key});

  @override
  State<SuggestedWorkoutScreen> createState() => _SuggestedWorkoutScreenState();
}

class _SuggestedWorkoutScreenState extends State<SuggestedWorkoutScreen> {
  var _focus = TrainingCategory.strength;

  @override
  Widget build(BuildContext context) {
    final suggestion = _suggestions[_focus]!;
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
                    onSelected: (_) => setState(() => _focus = item),
                  ),
                )
                .toList(),
          ),
          const SizedBox(height: 24),
          Card(
            color: AppColors.bone,
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    suggestion.title.toUpperCase(),
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      color: AppColors.voidBlack,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    suggestion.rationale,
                    style: const TextStyle(color: Color(0xFF454949)),
                  ),
                  const SizedBox(height: 20),
                  ...suggestion.items.map(
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
          ),
          const SizedBox(height: 18),
          const Text(
            'Esta sugestão usa regras pré-definidas e não substitui avaliação profissional. A personalização por IA será adicionada por um serviço seguro quando houver chave de API.',
          ),
        ],
      ),
    );
  }
}

class _Suggestion {
  const _Suggestion(this.title, this.rationale, this.items);
  final String title;
  final String rationale;
  final List<String> items;
}

const _suggestions = <TrainingCategory, _Suggestion>{
  TrainingCategory.strength: _Suggestion(
    'Força para membros superiores',
    'Prioriza grupos musculares e exercícios de força.',
    [
      'Supino reto — 3 séries',
      'Remada baixa — 3 séries',
      'Desenvolvimento — 3 séries',
    ],
  ),
  TrainingCategory.running: _Suggestion(
    'Base para corrida',
    'Prioriza pernas, core e estabilidade para sustentar a corrida.',
    [
      'Agachamento com peso corporal — 3 séries',
      'Ponte de glúteos — 3 séries',
      'Prancha — 3 séries',
    ],
  ),
  TrainingCategory.cycling: _Suggestion(
    'Base para ciclismo',
    'Prioriza pernas, core e mobilidade de quadril.',
    [
      'Leg press leve — 3 séries',
      'Elevação de panturrilhas — 3 séries',
      'Prancha lateral — 3 séries',
    ],
  ),
  TrainingCategory.swimming: _Suggestion(
    'Base geral para natação',
    'Equilibra ombros, costas, core e pernas.',
    [
      'Puxada frontal leve — 3 séries',
      'Rotação externa de ombro — 3 séries',
      'Prancha — 3 séries',
    ],
  ),
};
