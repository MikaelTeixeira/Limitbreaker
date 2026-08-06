import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/theme/app_theme.dart';
import '../../../core/widgets/brand_widgets.dart';
import '../../../shared/repositories/repositories.dart';

class FriendsScreen extends ConsumerWidget {
  const FriendsScreen({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final friends = ref.watch(friendsProvider);
    return Scaffold(
      appBar: AppBar(
        title: const Text('AMIGOS'),
        actions: [
          IconButton(
            tooltip: 'Adicionar amigo',
            onPressed: () => _showAddFriend(context),
            icon: const Icon(Icons.person_add_alt),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(AppSpacing.lg),
        children: [
          const SectionHeading('Seu círculo', eyebrow: 'Dados simulados'),
          const SizedBox(height: 12),
          ...friends.when(
            loading: () => [
              const Card(child: ListTile(title: Text('Carregando amigos...'))),
            ],
            error: (_, _) => [
              const Card(
                child: ListTile(
                  title: Text('Não foi possível carregar os amigos.'),
                ),
              ),
            ],
            data: (items) => items
                .map(
                  (friend) => Card(
                    child: ListTile(
                      minTileHeight: 76,
                      leading: CircleAvatar(
                        backgroundColor: AppColors.graphite,
                        child: Text(friend.displayName.substring(0, 1)),
                      ),
                      title: Text(
                        friend.displayName,
                        style: const TextStyle(fontWeight: FontWeight.w800),
                      ),
                      subtitle: Text(friend.recentActivity),
                      trailing: Text(friend.rankingLabel),
                      onTap: () => ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text(
                            'Chat demonstrativo — infraestrutura real está fora da Fase 1.',
                          ),
                        ),
                      ),
                    ),
                  ),
                )
                .toList(),
          ),
          const SizedBox(height: 24),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(Icons.group_add_outlined, size: 36),
                  const SizedBox(height: 16),
                  Text(
                    'CONVIDE QUEM\nNÃO ACEITA FICAR PARADO.',
                    style: Theme.of(context).textTheme.headlineMedium,
                  ),
                  const SizedBox(height: 12),
                  TextButton(
                    onPressed: () => _showAddFriend(context),
                    child: const Text('ADICIONAR AMIGO →'),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showAddFriend(BuildContext context) => showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    backgroundColor: AppColors.carbon,
    builder: (context) => SafeArea(
      child: Padding(
        padding: EdgeInsets.fromLTRB(
          24,
          24,
          24,
          24 + MediaQuery.viewInsetsOf(context).bottom,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SectionHeading(
              'Adicionar amigo',
              eyebrow: 'Convite simulado',
            ),
            const SizedBox(height: 18),
            Center(
              child: Container(
                width: 150,
                height: 150,
                color: AppColors.bone,
                alignment: Alignment.center,
                child: const Icon(
                  Icons.qr_code_2,
                  color: AppColors.voidBlack,
                  size: 128,
                ),
              ),
            ),
            const SizedBox(height: 12),
            const Center(
              child: SelectableText(
                'LB-VICTOR-2048',
                style: TextStyle(fontWeight: FontWeight.w900, letterSpacing: 2),
              ),
            ),
            const SizedBox(height: 18),
            const TextField(
              decoration: InputDecoration(hintText: 'Colar código'),
            ),
            const SizedBox(height: 12),
            FilledButton(
              onPressed: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Convite simulado enviado.')),
                );
              },
              child: const Text('ENVIAR CONVITE'),
            ),
          ],
        ),
      ),
    ),
  );
}
