import 'package:flutter/material.dart';

import '../../../app/theme/app_theme.dart';
import '../../../core/widgets/brand_widgets.dart';
import '../../../shared/models/models.dart';
import '../data/exercise_catalog.dart';

class ExercisesScreen extends StatefulWidget {
  const ExercisesScreen({super.key});

  @override
  State<ExercisesScreen> createState() => _ExercisesScreenState();
}

class _ExercisesScreenState extends State<ExercisesScreen> {
  TrainingCategory? _category;
  StrengthMuscleGroup? _group;

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(
      title: Text(_group?.label.toUpperCase() ?? 'EXERCÍCIOS'),
      leading: _category == null
          ? null
          : IconButton(
              tooltip: 'Voltar',
              icon: const Icon(Icons.arrow_back),
              onPressed: () => setState(() {
                if (_group != null) {
                  _group = null;
                } else {
                  _category = null;
                }
              }),
            ),
    ),
    body: switch ((_category, _group)) {
      (null, _) => _Categories(
        onSelected: (value) => setState(() => _category = value),
      ),
      (TrainingCategory.strength, null) => _MuscleGroups(
        onSelected: (value) => setState(() => _group = value),
      ),
      (TrainingCategory.strength, final group?) => _StrengthExercises(
        group: group,
      ),
      (final category?, _) => _ActivityOptions(category: category),
    },
  );
}

class _Categories extends StatelessWidget {
  const _Categories({required this.onSelected});
  final ValueChanged<TrainingCategory> onSelected;

  @override
  Widget build(BuildContext context) => ListView(
    padding: const EdgeInsets.all(AppSpacing.lg),
    children: [
      const SectionHeading(
        'Escolha uma categoria',
        eyebrow: 'Registre sua execução',
      ),
      const SizedBox(height: 16),
      ...TrainingCategory.values.map(
        (category) => Card(
          child: ListTile(
            leading: Icon(_icon(category)),
            title: Text(category.label),
            subtitle: Text(
              category == TrainingCategory.strength
                  ? 'Selecione o grupo muscular'
                  : 'Veja as modalidades disponíveis',
            ),
            trailing: const Icon(Icons.arrow_forward),
            onTap: () => onSelected(category),
          ),
        ),
      ),
    ],
  );

  IconData _icon(TrainingCategory category) => switch (category) {
    TrainingCategory.strength => Icons.fitness_center,
    TrainingCategory.running => Icons.directions_run,
    TrainingCategory.cycling => Icons.directions_bike,
    TrainingCategory.swimming => Icons.pool,
  };
}

class _MuscleGroups extends StatelessWidget {
  const _MuscleGroups({required this.onSelected});
  final ValueChanged<StrengthMuscleGroup> onSelected;

  @override
  Widget build(BuildContext context) => ListView(
    padding: const EdgeInsets.all(AppSpacing.lg),
    children: [
      const SectionHeading('Grupo muscular', eyebrow: 'Musculação'),
      const SizedBox(height: 16),
      ...StrengthMuscleGroup.values.map(
        (group) => Card(
          child: ListTile(
            title: Text(group.label),
            subtitle: Text(
              '${ExerciseCatalog.strengthExercises[group]!.length} exercícios',
            ),
            trailing: const Icon(Icons.arrow_forward),
            onTap: () => onSelected(group),
          ),
        ),
      ),
    ],
  );
}

class _StrengthExercises extends StatelessWidget {
  const _StrengthExercises({required this.group});
  final StrengthMuscleGroup group;

  @override
  Widget build(BuildContext context) => ListView(
    padding: const EdgeInsets.all(AppSpacing.lg),
    children: [
      const SectionHeading(
        'Exercícios',
        eyebrow: 'Fotos de execução serão adicionadas',
      ),
      const SizedBox(height: 16),
      ...ExerciseCatalog.strengthExercises[group]!.map(
        (exercise) => Card(
          child: ListTile(
            leading: const Icon(Icons.image_outlined),
            title: Text(exercise.name),
            subtitle: const Text('Carga e repetições: próxima fatia'),
            trailing: const Icon(Icons.arrow_forward),
          ),
        ),
      ),
    ],
  );
}

class _ActivityOptions extends StatelessWidget {
  const _ActivityOptions({required this.category});
  final TrainingCategory category;

  @override
  Widget build(BuildContext context) => ListView(
    padding: const EdgeInsets.all(AppSpacing.lg),
    children: [
      SectionHeading(category.label, eyebrow: 'Opções disponíveis'),
      const SizedBox(height: 16),
      ...ExerciseCatalog.activityOptions[category]!.map(
        (option) => Card(
          child: ListTile(
            leading: const Icon(Icons.playlist_add_check),
            title: Text(option),
            subtitle: const Text(
              'Registro de atividade será adicionado em seguida',
            ),
          ),
        ),
      ),
    ],
  );
}
