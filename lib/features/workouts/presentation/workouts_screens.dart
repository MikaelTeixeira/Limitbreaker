import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/theme/app_theme.dart';
import '../../../core/widgets/brand_widgets.dart';
import '../../../shared/models/models.dart';
import '../../../shared/repositories/repositories.dart';

class WorkoutsScreen extends ConsumerWidget {
  const WorkoutsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final plans = ref.watch(workoutPlansProvider);
    final sessions = ref.watch(workoutSessionsProvider);
    return Scaffold(
      appBar: AppBar(title: const Text('TREINOS')),
      body: ListView(
        padding: const EdgeInsets.all(AppSpacing.lg),
        children: [
          const SectionHeading('Registrar', eyebrow: 'Novo lançamento'),
          const SizedBox(height: 12),
          _ActionCard(
            icon: Icons.add_circle_outline,
            title: 'Registrar treino',
            subtitle: 'Corrida, musculação, ciclismo ou natação',
            onTap: () => context.push('/workouts/register'),
          ),
          const SizedBox(height: 8),
          _ActionCard(
            icon: Icons.fitness_center_outlined,
            title: 'Registrar carga',
            subtitle: 'Inclua exercícios, séries, repetições e carga',
            onTap: () => context.push('/workouts/register?category=strength'),
          ),
          const SizedBox(height: 28),
          const SectionHeading(
            'Rotinas sugeridas',
            eyebrow: 'Quando disponíveis',
          ),
          const SizedBox(height: 12),
          plans.when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (_, _) =>
                const _MessageCard('Não foi possível carregar as rotinas.'),
            data: (items) => Column(
              children: items
                  .map(
                    (plan) => Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: Card(
                        child: ListTile(
                          minTileHeight: 82,
                          leading: const Icon(Icons.fitness_center),
                          title: Text(
                            plan.name.toUpperCase(),
                            style: const TextStyle(fontWeight: FontWeight.w900),
                          ),
                          subtitle: Text(
                            '${plan.exerciseCount} exercícios · ${plan.estimatedMinutes} min',
                          ),
                          trailing: const Icon(Icons.arrow_forward),
                          onTap: () => context.push('/workouts/${plan.id}'),
                        ),
                      ),
                    ),
                  )
                  .toList(),
            ),
          ),
          const SizedBox(height: 28),
          const SectionHeading('Histórico', eyebrow: 'Nesta sessão'),
          const SizedBox(height: 12),
          sessions.when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (_, _) =>
                const _MessageCard('Não foi possível carregar o histórico.'),
            data: (items) => items.isEmpty
                ? const _MessageCard(
                    'Nenhum treino concluído. Escolha uma rotina para começar.',
                  )
                : Column(
                    children: items
                        .map(
                          (session) => Card(
                            child: ListTile(
                              leading: const Icon(
                                Icons.check_circle_outline,
                                color: AppColors.frost,
                              ),
                              title: Text(_sessionTitle(session)),
                              subtitle: Text(
                                '${session.duration.inMinutes} min · ${session.exercises.length} exercícios',
                              ),
                              trailing: const Icon(Icons.arrow_forward),
                            ),
                          ),
                        )
                        .toList(),
                  ),
          ),
        ],
      ),
    );
  }

  String _sessionTitle(WorkoutSession session) =>
      session.completedAt == null ? 'Treino em andamento' : 'Treino concluído';
}

class WorkoutSessionScreen extends ConsumerStatefulWidget {
  const WorkoutSessionScreen({super.key, required this.planId});
  final String planId;

  @override
  ConsumerState<WorkoutSessionScreen> createState() =>
      _WorkoutSessionScreenState();
}

class _WorkoutSessionScreenState extends ConsumerState<WorkoutSessionScreen> {
  WorkoutSession? _session;
  late final Map<String, TextEditingController> _sets;
  late final Map<String, TextEditingController> _repetitions;
  late final Map<String, TextEditingController> _loads;
  final _note = TextEditingController();

  @override
  void initState() {
    super.initState();
    _sets = {};
    _repetitions = {};
    _loads = {};
  }

  @override
  void dispose() {
    for (final controller in [
      ..._sets.values,
      ..._repetitions.values,
      ..._loads.values,
    ]) {
      controller.dispose();
    }
    _note.dispose();
    super.dispose();
  }

  TextEditingController _controller(
    Map<String, TextEditingController> controllers,
    String id,
    String value,
  ) => controllers.putIfAbsent(id, () => TextEditingController(text: value));

  Future<void> _start(WorkoutPlan plan) async {
    final session = await ref
        .read(workoutRepositoryProvider)
        .startWorkout(plan, DateTime.now());
    if (mounted) setState(() => _session = session);
  }

  Future<void> _complete(WorkoutPlan plan) async {
    final session = _session;
    if (session == null) return;
    final exercises = plan.exercises.map((item) {
      final sets =
          int.tryParse(
            _controller(_sets, item.exercise.id, '${item.targetSets}').text,
          ) ??
          item.targetSets;
      final repetitions =
          int.tryParse(
            _controller(_repetitions, item.exercise.id, '10').text,
          ) ??
          10;
      final load =
          double.tryParse(
            _controller(
              _loads,
              item.exercise.id,
              '0',
            ).text.replaceAll(',', '.'),
          ) ??
          0;
      return PerformedExercise(
        exercise: item.exercise,
        sets: List.generate(
          sets.clamp(1, 12),
          (_) => ExerciseSet(
            repetitions: repetitions.clamp(1, 100),
            loadKg: load.clamp(0, 1000),
          ),
        ),
      );
    }).toList();
    await ref
        .read(workoutRepositoryProvider)
        .completeWorkout(
          session.id,
          duration: const Duration(minutes: 45),
          exercises: exercises,
          note: _note.text.trim().isEmpty ? null : _note.text.trim(),
        );
    ref.invalidate(workoutSessionsProvider);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Treino concluído e salvo localmente.')),
      );
      context.pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final plans = ref.watch(workoutPlansProvider);
    return plans.when(
      loading: () =>
          const Scaffold(body: Center(child: CircularProgressIndicator())),
      error: (_, _) => const Scaffold(
        body: Center(child: Text('Não foi possível abrir o treino.')),
      ),
      data: (items) {
        final matches = items.where((plan) => plan.id == widget.planId);
        if (matches.isEmpty) {
          return const Scaffold(
            body: Center(child: Text('Rotina não encontrada.')),
          );
        }
        final plan = matches.first;
        return Scaffold(
          appBar: AppBar(title: Text(plan.name.toUpperCase())),
          body: ListView(
            padding: const EdgeInsets.all(AppSpacing.lg),
            children: [
              Text(
                _session == null
                    ? 'PRONTO PARA COMEÇAR?'
                    : 'REGISTRE SUAS SÉRIES',
                style: Theme.of(context).textTheme.displayMedium,
              ),
              const SizedBox(height: 8),
              Text(
                '${plan.groups.join(' + ')} · ${plan.estimatedMinutes} min estimados',
              ),
              const SizedBox(height: 24),
              if (_session == null)
                FilledButton.icon(
                  onPressed: () => _start(plan),
                  icon: const Icon(Icons.play_arrow),
                  label: const Text('INICIAR TREINO'),
                )
              else ...[
                ...plan.exercises.map(
                  (item) => _ExerciseInput(
                    item: item,
                    sets: _controller(
                      _sets,
                      item.exercise.id,
                      '${item.targetSets}',
                    ),
                    repetitions: _controller(
                      _repetitions,
                      item.exercise.id,
                      '10',
                    ),
                    load: _controller(_loads, item.exercise.id, '0'),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: _note,
                  maxLines: 3,
                  decoration: const InputDecoration(
                    labelText: 'Observação opcional',
                    hintText: 'Como você se sentiu?',
                  ),
                ),
                const SizedBox(height: 16),
                FilledButton.icon(
                  onPressed: () => _complete(plan),
                  icon: const Icon(Icons.check),
                  label: const Text('CONCLUIR TREINO'),
                ),
              ],
            ],
          ),
        );
      },
    );
  }
}

class _ExerciseInput extends StatelessWidget {
  const _ExerciseInput({
    required this.item,
    required this.sets,
    required this.repetitions,
    required this.load,
  });
  final PlannedExercise item;
  final TextEditingController sets;
  final TextEditingController repetitions;
  final TextEditingController load;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: 12),
    child: Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              item.exercise.name.toUpperCase(),
              style: const TextStyle(fontWeight: FontWeight.w900),
            ),
            const SizedBox(height: 4),
            Text(item.exercise.muscleGroup),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: sets,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(labelText: 'Séries'),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: TextField(
                    controller: repetitions,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(labelText: 'Repetições'),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: TextField(
                    controller: load,
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                    decoration: const InputDecoration(labelText: 'Carga kg'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    ),
  );
}

class _ActionCard extends StatelessWidget {
  const _ActionCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => Card(
    child: ListTile(
      minTileHeight: 80,
      leading: Icon(icon, color: AppColors.frost),
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.w900)),
      subtitle: Text(subtitle),
      trailing: const Icon(Icons.arrow_forward),
      onTap: onTap,
    ),
  );
}

class _MessageCard extends StatelessWidget {
  const _MessageCard(this.message);
  final String message;
  @override
  Widget build(BuildContext context) => Card(
    child: Padding(padding: const EdgeInsets.all(18), child: Text(message)),
  );
}
