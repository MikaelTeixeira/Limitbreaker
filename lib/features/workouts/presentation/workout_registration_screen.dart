import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/theme/app_theme.dart';
import '../../../core/widgets/brand_widgets.dart';
import '../../../shared/models/models.dart';
import '../../../shared/repositories/repositories.dart';
import '../../exercises/data/exercise_catalog.dart';

class WorkoutRegistrationScreen extends ConsumerStatefulWidget {
  const WorkoutRegistrationScreen({super.key, this.initialCategory});
  final TrainingCategory? initialCategory;

  @override
  ConsumerState<WorkoutRegistrationScreen> createState() =>
      _WorkoutRegistrationScreenState();
}

class _WorkoutRegistrationScreenState
    extends ConsumerState<WorkoutRegistrationScreen> {
  TrainingCategory? _category;
  StrengthMuscleGroup? _muscleGroup;
  final List<_ExerciseDraft> _exercises = [];
  final _duration = TextEditingController();
  final _distance = TextEditingController();
  final _pace = TextEditingController();

  @override
  void initState() {
    super.initState();
    _category = widget.initialCategory;
  }

  @override
  void dispose() {
    _duration.dispose();
    _distance.dispose();
    _pace.dispose();
    for (final draft in _exercises) {
      draft.dispose();
    }
    super.dispose();
  }

  Future<void> _finalizeStrength() async {
    if (_exercises.isEmpty || _exercises.any((item) => !item.isValid)) {
      _message(
        'Adicione ao menos um exercício com séries, repetições e carga válidas.',
      );
      return;
    }
    final now = DateTime.now();
    final plan = WorkoutPlan(
      id: 'manual-${now.millisecondsSinceEpoch}',
      name: 'Musculação',
      groups: _exercises
          .map((item) => item.exercise.muscleGroup)
          .toSet()
          .toList(),
      exerciseCount: _exercises.length,
    );
    final repository = ref.read(workoutRepositoryProvider);
    final session = await repository.startWorkout(plan, now);
    await repository.completeWorkout(
      session.id,
      duration: Duration.zero,
      exercises: _exercises.map((item) => item.toPerformedExercise()).toList(),
      completedAt: now,
    );
    ref.invalidate(workoutSessionsProvider);
    if (mounted) Navigator.of(context).pop();
  }

  Future<void> _finalizeActivity() async {
    final category = _category;
    final minutes = int.tryParse(_duration.text.trim());
    if (category == null || minutes == null || minutes <= 0) {
      _message('Informe uma duração válida.');
      return;
    }
    double? distanceKm;
    if (category == TrainingCategory.running ||
        category == TrainingCategory.cycling) {
      final paceMinutes = _parsePace(_pace.text);
      if (paceMinutes == null || paceMinutes <= 0) {
        _message('Informe o pace no formato min:seg por km.');
        return;
      }
      distanceKm = minutes / paceMinutes;
    } else {
      final metres = double.tryParse(_distance.text.replaceAll(',', '.'));
      if (metres == null || metres <= 0) {
        _message('Informe a distância nadada em metros.');
        return;
      }
      distanceKm = metres / 1000;
    }
    await ref
        .read(appRepositoryProvider)
        .addActivity(
          categoryId: category.name,
          performedAt: DateTime.now(),
          duration: Duration(minutes: minutes),
          distanceKm: distanceKm,
        );
    ref.invalidate(activitiesProvider);
    ref.invalidate(personalRecordsProvider);
    if (mounted) Navigator.of(context).pop();
  }

  double? _parsePace(String text) {
    final parts = text.trim().split(':');
    if (parts.length != 2) return null;
    final minutes = int.tryParse(parts[0]);
    final seconds = int.tryParse(parts[1]);
    if (minutes == null || seconds == null || seconds < 0 || seconds >= 60) {
      return null;
    }
    return minutes + seconds / 60;
  }

  void _message(String text) =>
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(text)));

  Future<void> _addExercise() async {
    final group = _muscleGroup;
    if (group == null) {
      _message('Escolha um grupo muscular antes de adicionar exercícios.');
      return;
    }
    final selected = await showModalBottomSheet<Exercise>(
      context: context,
      isScrollControlled: true,
      builder: (_) => _ExercisePicker(group: group),
    );
    if (selected == null ||
        _exercises.any((item) => item.exercise.id == selected.id)) {
      return;
    }
    setState(() => _exercises.add(_ExerciseDraft(selected)));
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('REGISTRAR TREINO')),
    body: ListView(
      padding: const EdgeInsets.all(AppSpacing.lg),
      children: [
        if (_category == null) ...[
          const SectionHeading(
            'Qual treino foi feito?',
            eyebrow: 'Escolha uma modalidade',
          ),
          const SizedBox(height: 12),
          ...TrainingCategory.values.map(
            (category) => Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Card(
                child: ListTile(
                  leading: Icon(_iconFor(category)),
                  title: Text(category.label),
                  trailing: const Icon(Icons.arrow_forward),
                  onTap: () => setState(() => _category = category),
                ),
              ),
            ),
          ),
        ] else if (_category == TrainingCategory.strength)
          ..._strengthForm()
        else
          ..._activityForm(),
      ],
    ),
  );

  List<Widget> _strengthForm() => [
    const SectionHeading(
      'Grupo muscular',
      eyebrow: 'Selecione para buscar exercícios',
    ),
    const SizedBox(height: 10),
    Wrap(
      spacing: 8,
      runSpacing: 8,
      children: StrengthMuscleGroup.values
          .map(
            (group) => ChoiceChip(
              label: Text(group.label),
              selected: _muscleGroup == group,
              onSelected: (_) => setState(() => _muscleGroup = group),
            ),
          )
          .toList(),
    ),
    const SizedBox(height: 24),
    SectionHeading('Exercícios', eyebrow: '${_exercises.length} adicionados'),
    const SizedBox(height: 10),
    if (_exercises.isEmpty)
      const _EmptyExercises()
    else
      ..._exercises.map(
        (draft) => _ExerciseEntry(
          draft: draft,
          onRemove: () => setState(() {
            draft.dispose();
            _exercises.remove(draft);
          }),
        ),
      ),
    OutlinedButton.icon(
      onPressed: _addExercise,
      icon: const Icon(Icons.add),
      label: const Text('ADICIONAR EXERCÍCIO'),
    ),
    const SizedBox(height: 16),
    FilledButton.icon(
      onPressed: _finalizeStrength,
      icon: const Icon(Icons.check),
      label: const Text('FINALIZAR TREINO'),
    ),
  ];

  List<Widget> _activityForm() {
    final isSwim = _category == TrainingCategory.swimming;
    return [
      SectionHeading(_category!.label, eyebrow: 'Dados do treino'),
      const SizedBox(height: 14),
      TextField(
        controller: _duration,
        keyboardType: TextInputType.number,
        decoration: const InputDecoration(labelText: 'Duração (minutos)'),
      ),
      const SizedBox(height: 12),
      TextField(
        controller: isSwim ? _distance : _pace,
        keyboardType: isSwim
            ? const TextInputType.numberWithOptions(decimal: true)
            : TextInputType.datetime,
        decoration: InputDecoration(
          labelText: isSwim ? 'Distância nadada (metros)' : 'Pace (min:seg/km)',
          hintText: isSwim ? 'Ex.: 1000' : 'Ex.: 05:30',
        ),
      ),
      const SizedBox(height: 18),
      FilledButton.icon(
        onPressed: _finalizeActivity,
        icon: const Icon(Icons.check),
        label: const Text('FINALIZAR TREINO'),
      ),
    ];
  }

  IconData _iconFor(TrainingCategory category) => switch (category) {
    TrainingCategory.strength => Icons.fitness_center,
    TrainingCategory.running => Icons.directions_run,
    TrainingCategory.cycling => Icons.directions_bike,
    TrainingCategory.swimming => Icons.pool,
  };
}

class _ExerciseDraft {
  _ExerciseDraft(this.exercise);
  final Exercise exercise;
  final sets = TextEditingController(text: '3');
  final repetitions = TextEditingController(text: '10');
  final load = TextEditingController(text: '0');

  bool get isValid {
    final parsedLoad = double.tryParse(load.text.replaceAll(',', '.'));
    return (int.tryParse(sets.text) ?? 0) > 0 &&
        (int.tryParse(repetitions.text) ?? 0) > 0 &&
        parsedLoad != null &&
        parsedLoad >= 0;
  }

  PerformedExercise toPerformedExercise() => PerformedExercise(
    exercise: exercise,
    sets: List.generate(
      int.parse(sets.text),
      (_) => ExerciseSet(
        repetitions: int.parse(repetitions.text),
        loadKg: double.parse(load.text.replaceAll(',', '.')),
      ),
    ),
  );

  void dispose() {
    sets.dispose();
    repetitions.dispose();
    load.dispose();
  }
}

class _ExerciseEntry extends StatelessWidget {
  const _ExerciseEntry({required this.draft, required this.onRemove});
  final _ExerciseDraft draft;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) => Card(
    margin: const EdgeInsets.only(bottom: 10),
    child: Padding(
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const _PendingImage(),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  draft.exercise.name,
                  style: const TextStyle(fontWeight: FontWeight.w900),
                ),
              ),
              IconButton(onPressed: onRemove, icon: const Icon(Icons.close)),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              _NumberField(controller: draft.sets, label: 'Séries'),
              const SizedBox(width: 8),
              _NumberField(controller: draft.repetitions, label: 'Repetições'),
              const SizedBox(width: 8),
              _NumberField(
                controller: draft.load,
                label: 'Carga (kg)',
                decimal: true,
              ),
            ],
          ),
        ],
      ),
    ),
  );
}

class _NumberField extends StatelessWidget {
  const _NumberField({
    required this.controller,
    required this.label,
    this.decimal = false,
  });
  final TextEditingController controller;
  final String label;
  final bool decimal;
  @override
  Widget build(BuildContext context) => Expanded(
    child: TextField(
      controller: controller,
      keyboardType: TextInputType.numberWithOptions(decimal: decimal),
      decoration: InputDecoration(labelText: label),
    ),
  );
}

class _PendingImage extends StatelessWidget {
  const _PendingImage();
  @override
  Widget build(BuildContext context) => Container(
    width: 56,
    height: 56,
    color: AppColors.graphite,
    alignment: Alignment.center,
    child: const Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(Icons.image_outlined, size: 18),
        Text(
          'IMAGEM\nPENDENTE',
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 7, fontWeight: FontWeight.w800),
        ),
      ],
    ),
  );
}

class _EmptyExercises extends StatelessWidget {
  const _EmptyExercises();
  @override
  Widget build(BuildContext context) => const Padding(
    padding: EdgeInsets.only(bottom: 14),
    child: Text(
      'Nenhum exercício adicionado. Escolha um grupo e pesquise pelo nome.',
    ),
  );
}

class _ExercisePicker extends StatefulWidget {
  const _ExercisePicker({required this.group});
  final StrengthMuscleGroup group;
  @override
  State<_ExercisePicker> createState() => _ExercisePickerState();
}

class _ExercisePickerState extends State<_ExercisePicker> {
  var _query = '';
  @override
  Widget build(BuildContext context) {
    final items = ExerciseCatalog.strengthExercises[widget.group]!
        .where((item) => item.name.toLowerCase().contains(_query.toLowerCase()))
        .toList();
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              autofocus: true,
              onChanged: (value) => setState(() => _query = value),
              decoration: const InputDecoration(
                prefixIcon: Icon(Icons.search),
                labelText: 'Pesquisar exercício',
              ),
            ),
            const SizedBox(height: 12),
            Flexible(
              child: ListView(
                shrinkWrap: true,
                children: items
                    .map(
                      (item) => ListTile(
                        title: Text(item.name),
                        subtitle: Text(item.muscleGroup),
                        onTap: () => Navigator.pop(context, item),
                      ),
                    )
                    .toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
