import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/theme/app_theme.dart';
import '../../../core/widgets/brand_widgets.dart';
import '../../../core/widgets/radar_chart.dart';
import '../../../shared/repositories/repositories.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final muscles = ref.watch(muscleAttributesProvider);
    final categories = ref.watch(categoryAttributesProvider);
    return Scaffold(
      appBar: AppBar(
        title: const Text('PERFIL'),
        actions: [
          IconButton(
            tooltip: 'Editar perfil',
            onPressed: () => _notice(context),
            icon: const Icon(Icons.edit_outlined),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(AppSpacing.lg),
        children: [
          const Center(
            child: CircleAvatar(
              radius: 44,
              backgroundColor: AppColors.graphite,
              child: Text(
                '—',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.w900),
              ),
            ),
          ),
          const SizedBox(height: 14),
          Text(
            'SEU PERFIL',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.headlineMedium,
          ),
          const SizedBox(height: 4),
          Text(
            'SEM TREINOS REGISTRADOS · RANKING #1',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.labelSmall,
          ),
          const SizedBox(height: 24),
          const Row(
            children: [
              MetricTile(value: '0', label: 'sequência', accent: true),
              MetricTile(value: '0', label: 'treinos'),
              MetricTile(value: '0', label: 'conquistas'),
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
          const SizedBox(height: 18),
        ],
      ),
    );
  }

  void _notice(BuildContext context) =>
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Edição completa de perfil será adicionada em uma próxima fase.',
          ),
        ),
      );
}
