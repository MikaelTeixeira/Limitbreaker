import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/theme/app_theme.dart';
import '../../../core/widgets/brand_widgets.dart';
import '../../../core/widgets/radar_chart.dart';
import '../../../shared/data/local_api.dart';
import '../../../shared/models/models.dart';
import '../../../shared/repositories/repositories.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final muscles = ref.watch(muscleAttributesProvider);
    final categories = ref.watch(categoryAttributesProvider);
    final achievements = ref.watch(achievementsProvider);
    final profile = ref.watch(authenticatedProfileProvider);
    final sessions = ref.watch(workoutSessionsProvider);
    return Scaffold(
      appBar: AppBar(
        title: const Text('PERFIL'),
        actions: [
          IconButton(
            tooltip: 'Editar perfil',
            onPressed: profile.value == null
                ? null
                : () => _editProfile(context, ref, profile.value!),
            icon: const Icon(Icons.edit_outlined),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(AppSpacing.lg),
        children: [
          Center(
            child: CircleAvatar(
              radius: 44,
              backgroundColor: AppColors.graphite,
              child: Text(
                profile.when(
                  loading: () => '…',
                  error: (_, _) => '!',
                  data: (data) => _initials(data.displayName),
                ),
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ),
          ),
          const SizedBox(height: 14),
          profile.when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (_, _) => const Text(
              'NÃO FOI POSSÍVEL CARREGAR O PERFIL',
              textAlign: TextAlign.center,
            ),
            data: (data) => Text(
              data.displayName.toUpperCase(),
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.headlineMedium,
            ),
          ),
          const SizedBox(height: 4),
          profile.when(
            loading: () => const SizedBox.shrink(),
            error: (_, _) => TextButton(
              onPressed: () => ref.invalidate(authenticatedProfileProvider),
              child: const Text('TENTAR NOVAMENTE'),
            ),
            data: (data) => Text(
              '${data.email} · ${data.age} anos · ${data.heightCm.toStringAsFixed(1)} cm · ${data.weightKg.toStringAsFixed(1)} kg',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.labelSmall,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'SEM PONTUAÇÃO OFICIAL',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.labelSmall,
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              const MetricTile(value: '0', label: 'sequência', accent: true),
              MetricTile(
                value: sessions.value?.length.toString() ?? '—',
                label: 'treinos',
              ),
              MetricTile(
                value: achievements.value?.length.toString() ?? '—',
                label: 'conquistas',
              ),
            ],
          ),
          const SizedBox(height: 32),
          const SectionHeading('Mapa muscular', eyebrow: 'Aguardando dados'),
          const SizedBox(height: 12),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: muscles.when(
                loading: () => const SizedBox(
                  height: 280,
                  child: Center(child: CircularProgressIndicator()),
                ),
                error: (_, _) => const SizedBox(
                  height: 220,
                  child: Center(
                    child: Text('Não foi possível carregar o gráfico.'),
                  ),
                ),
                data: (data) => data.isEmpty
                    ? const SizedBox(
                        height: 220,
                        child: Center(
                          child: Text(
                            'Conclua treinos para gerar seu mapa muscular.',
                          ),
                        ),
                      )
                    : RadarChart(attributes: data),
              ),
            ),
          ),
          const SizedBox(height: 28),
          const SectionHeading('Modalidades', eyebrow: 'Aguardando dados'),
          const SizedBox(height: 12),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: categories.when(
                loading: () => const SizedBox(
                  height: 280,
                  child: Center(child: CircularProgressIndicator()),
                ),
                error: (_, _) => const SizedBox(
                  height: 220,
                  child: Center(
                    child: Text('Não foi possível carregar o gráfico.'),
                  ),
                ),
                data: (data) => data.isEmpty
                    ? const SizedBox(
                        height: 220,
                        child: Center(
                          child: Text(
                            'Registre atividades para gerar seu gráfico.',
                          ),
                        ),
                      )
                    : RadarChart(attributes: data),
              ),
            ),
          ),
          const SizedBox(height: 28),
          const SectionHeading('Histórico', eyebrow: 'Nenhum registro'),
          const SizedBox(height: 12),
          const Card(
            child: ListTile(
              leading: Icon(Icons.history_toggle_off),
              title: Text('Nenhum treino ou atividade registrado'),
              subtitle: Text(
                'Seu histórico aparecerá aqui após o primeiro registro.',
              ),
            ),
          ),
          const SizedBox(height: 28),
          const SectionHeading('Conquistas', eyebrow: 'Registros liberados'),
          const SizedBox(height: 12),
          achievements.when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (_, _) => const Card(
              child: ListTile(
                title: Text('Não foi possível carregar as conquistas.'),
              ),
            ),
            data: (items) => items.isEmpty
                ? const Card(
                    child: ListTile(
                      leading: Icon(Icons.military_tech_outlined),
                      title: Text('Nenhuma conquista liberada'),
                      subtitle: Text(
                        'As conquistas aparecerão aqui após serem alcançadas.',
                      ),
                    ),
                  )
                : Column(
                    children: items
                        .map(
                          (item) => Card(
                            child: ListTile(
                              leading: const Icon(Icons.military_tech_outlined),
                              title: Text(item.title),
                            ),
                          ),
                        )
                        .toList(),
                  ),
          ),
          const SizedBox(height: 18),
        ],
      ),
    );
  }

  String _initials(String name) {
    final parts = name.trim().split(RegExp(r'\s+'));
    if (parts.isEmpty || parts.first.isEmpty) return '—';
    return parts.take(2).map((part) => part[0].toUpperCase()).join();
  }

  Future<void> _editProfile(
    BuildContext context,
    WidgetRef ref,
    UserProfile profile,
  ) async {
    final saved = await showDialog<bool>(
      context: context,
      builder: (_) => _EditProfileDialog(profile: profile),
    );
    if (saved == true) {
      ref.invalidate(authenticatedProfileProvider);
      if (context.mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Perfil atualizado.')));
      }
    }
  }
}

class _EditProfileDialog extends StatefulWidget {
  const _EditProfileDialog({required this.profile});

  final UserProfile profile;

  @override
  State<_EditProfileDialog> createState() => _EditProfileDialogState();
}

class _EditProfileDialogState extends State<_EditProfileDialog> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _name;
  late final TextEditingController _age;
  late final TextEditingController _height;
  late final TextEditingController _weight;
  var _saving = false;

  @override
  void initState() {
    super.initState();
    _name = TextEditingController(text: widget.profile.displayName);
    _age = TextEditingController(text: widget.profile.age.toString());
    _height = TextEditingController(text: widget.profile.heightCm.toString());
    _weight = TextEditingController(text: widget.profile.weightKg.toString());
  }

  @override
  void dispose() {
    _name.dispose();
    _age.dispose();
    _height.dispose();
    _weight.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => AlertDialog(
    title: const Text('Editar perfil'),
    content: Form(
      key: _formKey,
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextFormField(
              controller: _name,
              decoration: const InputDecoration(labelText: 'Nome'),
              validator: (value) => _required(value, 2, 50, 'Informe o nome.'),
            ),
            TextFormField(
              initialValue: widget.profile.email,
              enabled: false,
              decoration: const InputDecoration(labelText: 'E-mail'),
            ),
            TextFormField(
              controller: _age,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: 'Idade'),
              validator: (value) => _integer(value, 13, 120),
            ),
            TextFormField(
              controller: _height,
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              decoration: const InputDecoration(labelText: 'Altura (cm)'),
              validator: (value) => _number(value, 80, 250),
            ),
            TextFormField(
              controller: _weight,
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              decoration: const InputDecoration(labelText: 'Peso (kg)'),
              validator: (value) => _number(value, 20, 400),
            ),
          ],
        ),
      ),
    ),
    actions: [
      TextButton(
        onPressed: _saving ? null : () => Navigator.pop(context, false),
        child: const Text('CANCELAR'),
      ),
      FilledButton(
        onPressed: _saving ? null : _save,
        child: Text(_saving ? 'SALVANDO…' : 'SALVAR'),
      ),
    ],
  );

  String? _required(String? value, int min, int max, String message) {
    final length = value?.trim().length ?? 0;
    return length < min || length > max ? message : null;
  }

  String? _integer(String? value, int min, int max) {
    final parsed = int.tryParse(value?.trim() ?? '');
    return parsed == null || parsed < min || parsed > max
        ? 'Informe um valor entre $min e $max.'
        : null;
  }

  String? _number(String? value, double min, double max) {
    final parsed = double.tryParse((value ?? '').trim().replaceAll(',', '.'));
    return parsed == null || parsed < min || parsed > max
        ? 'Informe um valor entre ${min.toInt()} e ${max.toInt()}.'
        : null;
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _saving = true);
    try {
      await LocalApi.instance.updateProfile(
        displayName: _name.text.trim(),
        age: int.parse(_age.text.trim()),
        heightCm: double.parse(_height.text.trim().replaceAll(',', '.')),
        weightKg: double.parse(_weight.text.trim().replaceAll(',', '.')),
      );
      if (mounted) Navigator.pop(context, true);
    } on LocalApiException catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(error.message)));
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }
}
