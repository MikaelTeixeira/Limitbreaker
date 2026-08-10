import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/theme/app_theme.dart';
import '../../../core/widgets/brand_widgets.dart';
import '../../../shared/models/models.dart';
import '../../../shared/repositories/repositories.dart';

class FriendsScreen extends ConsumerWidget {
  const FriendsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final friends = ref.watch(friendsProvider);
    final requests = ref.watch(friendRequestsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('AMIGOS'),
        actions: [
          IconButton(
            tooltip: 'Adicionar amigo',
            onPressed: () => _showAddFriend(context, ref),
            icon: const Icon(Icons.person_add_alt),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(AppSpacing.lg),
        children: [
          ..._buildRequests(context, ref, requests),
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
                            'Chat demonstrativo — infraestrutura real está fora da Fase 3.',
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
                    onPressed: () => _showAddFriend(context, ref),
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

  List<Widget> _buildRequests(
    BuildContext context,
    WidgetRef ref,
    AsyncValue<List<FriendRequest>> requests,
  ) {
    return requests.when(
      loading: () => const [SizedBox.shrink()],
      error: (_, _) => const [SizedBox.shrink()],
      data: (items) {
        final received = items
            .where(
              (request) =>
                  request.status == FriendRequestStatus.pending &&
                  request.direction == FriendRequestDirection.received,
            )
            .toList();
        final sent = items
            .where(
              (request) =>
                  request.status == FriendRequestStatus.pending &&
                  request.direction == FriendRequestDirection.sent,
            )
            .toList();
        if (received.isEmpty && sent.isEmpty) return const [SizedBox.shrink()];

        return [
          const SectionHeading('Convites', eyebrow: 'Aguardando resposta'),
          const SizedBox(height: 12),
          ...received.map(
            (request) => Card(
              child: ListTile(
                leading: CircleAvatar(child: Text(request.displayName[0])),
                title: Text(request.displayName),
                subtitle: const Text('Quer entrar no seu círculo'),
                trailing: Wrap(
                  spacing: 2,
                  children: [
                    IconButton(
                      tooltip: 'Recusar convite',
                      onPressed: () => _respond(
                        context,
                        ref,
                        request,
                        FriendRequestStatus.declined,
                      ),
                      icon: const Icon(Icons.close),
                    ),
                    IconButton.filled(
                      tooltip: 'Aceitar convite',
                      onPressed: () => _respond(
                        context,
                        ref,
                        request,
                        FriendRequestStatus.accepted,
                      ),
                      icon: const Icon(Icons.check),
                    ),
                  ],
                ),
              ),
            ),
          ),
          ...sent.map(
            (request) => Card(
              child: ListTile(
                leading: const CircleAvatar(child: Icon(Icons.schedule)),
                title: const Text('Convite enviado'),
                subtitle: Text(
                  'Código ${request.fromUserId} aguardando aceite',
                ),
              ),
            ),
          ),
          const SizedBox(height: 24),
        ];
      },
    );
  }

  Future<void> _respond(
    BuildContext context,
    WidgetRef ref,
    FriendRequest request,
    FriendRequestStatus status,
  ) async {
    await ref.read(appRepositoryProvider).respondToRequest(request.id, status);
    ref.invalidate(friendRequestsProvider);
    if (status == FriendRequestStatus.accepted) {
      ref.invalidate(friendsProvider);
    }
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          status == FriendRequestStatus.accepted
              ? '${request.displayName} entrou no seu círculo.'
              : 'Convite de ${request.displayName} recusado.',
        ),
      ),
    );
  }

  void _showAddFriend(BuildContext context, WidgetRef ref) {
    final controller = TextEditingController();
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.carbon,
      builder: (sheetContext) => SafeArea(
        child: Padding(
          padding: EdgeInsets.fromLTRB(
            24,
            24,
            24,
            24 + MediaQuery.viewInsetsOf(sheetContext).bottom,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SectionHeading('Adicionar amigo', eyebrow: 'Convite local'),
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
                  style: TextStyle(
                    fontWeight: FontWeight.w900,
                    letterSpacing: 2,
                  ),
                ),
              ),
              const SizedBox(height: 18),
              TextField(
                controller: controller,
                textCapitalization: TextCapitalization.characters,
                decoration: const InputDecoration(hintText: 'Colar código'),
              ),
              const SizedBox(height: 12),
              FilledButton(
                onPressed: () async {
                  try {
                    await ref
                        .read(appRepositoryProvider)
                        .sendRequest(controller.text);
                    ref.invalidate(friendRequestsProvider);
                    if (!sheetContext.mounted) return;
                    Navigator.pop(sheetContext);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Convite enviado.')),
                    );
                  } on ArgumentError {
                    ScaffoldMessenger.of(sheetContext).showSnackBar(
                      const SnackBar(content: Text('Informe um código.')),
                    );
                  }
                },
                child: const Text('ENVIAR CONVITE'),
              ),
            ],
          ),
        ),
      ),
    ).whenComplete(controller.dispose);
  }
}
