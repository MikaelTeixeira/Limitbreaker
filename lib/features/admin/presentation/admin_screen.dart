import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../app/theme/app_theme.dart';
import '../../../core/widgets/brand_widgets.dart';
import '../../../shared/data/local_api.dart';

class AdminScreen extends StatefulWidget {
  const AdminScreen({super.key});

  @override
  State<AdminScreen> createState() => _AdminScreenState();
}

class _AdminScreenState extends State<AdminScreen> {
  var _section = 0;
  var _refresh = 0;

  @override
  void initState() {
    super.initState();
    _guardAccess();
  }

  Future<void> _guardAccess() async {
    if (await LocalApi.instance.isAdministrator() || !mounted) return;
    context.go('/login');
  }

  void _reload() => setState(() => _refresh++);

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(
      title: const Text('ADMINISTRAÇÃO'),
      actions: [
        IconButton(
          tooltip: 'Sair',
          onPressed: () async {
            await LocalApi.instance.signOut();
            if (mounted) context.go('/login');
          },
          icon: const Icon(Icons.logout),
        ),
      ],
    ),
    body: IndexedStack(
      index: _section,
      children: [
        _AdminHome(onEvent: _newEvent),
        _AdminExercises(key: ValueKey(_refresh), onChanged: _reload),
        _AdminUsers(key: ValueKey(_refresh), onChanged: _reload),
      ],
    ),
    bottomNavigationBar: NavigationBar(
      selectedIndex: _section,
      onDestinationSelected: (value) => setState(() => _section = value),
      destinations: const [
        NavigationDestination(
          icon: Icon(Icons.admin_panel_settings_outlined),
          selectedIcon: Icon(Icons.admin_panel_settings),
          label: 'Painel',
        ),
        NavigationDestination(
          icon: Icon(Icons.fitness_center_outlined),
          selectedIcon: Icon(Icons.fitness_center),
          label: 'Exercícios',
        ),
        NavigationDestination(
          icon: Icon(Icons.manage_accounts_outlined),
          selectedIcon: Icon(Icons.manage_accounts),
          label: 'Contas',
        ),
      ],
    ),
  );

  Future<void> _newEvent() async {
    final controller = TextEditingController();
    final title = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Criar evento'),
        content: TextField(
          controller: controller,
          autofocus: true,
          decoration: const InputDecoration(labelText: 'Título do evento'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('CANCELAR'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, controller.text),
            child: const Text('CRIAR'),
          ),
        ],
      ),
    );
    if (title == null || title.trim().isEmpty) return;
    try {
      await LocalApi.instance.createAdminEvent(title.trim());
      if (mounted)
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Evento criado.')));
    } on LocalApiException catch (error) {
      if (mounted)
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(error.message)));
    }
  }
}

class _AdminHome extends StatelessWidget {
  const _AdminHome({required this.onEvent});
  final Future<void> Function() onEvent;

  @override
  Widget build(BuildContext context) => ListView(
    padding: const EdgeInsets.all(AppSpacing.lg),
    children: [
      const SectionHeading('Painel administrativo', eyebrow: 'Acesso restrito'),
      const SizedBox(height: 12),
      const Card(
        child: ListTile(
          leading: Icon(Icons.verified_user_outlined, color: AppColors.frost),
          title: Text('Controle protegido'),
          subtitle: Text(
            'As permissões são conferidas pela API, não apenas pela tela.',
          ),
        ),
      ),
      const SizedBox(height: 12),
      FilledButton.icon(
        onPressed: onEvent,
        icon: const Icon(Icons.emoji_events_outlined),
        label: const Text('CRIAR EVENTO'),
      ),
      const SizedBox(height: 10),
      const Text(
        'Use as abas inferiores para administrar exercícios e contas.',
      ),
    ],
  );
}

class _AdminExercises extends StatefulWidget {
  const _AdminExercises({super.key, required this.onChanged});
  final VoidCallback onChanged;
  @override
  State<_AdminExercises> createState() => _AdminExercisesState();
}

class _AdminExercisesState extends State<_AdminExercises> {
  late Future<List<Map<String, dynamic>>> _items;
  @override
  void initState() {
    super.initState();
    _items = LocalApi.instance.adminExercises();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    floatingActionButton: FloatingActionButton.extended(
      onPressed: _create,
      icon: const Icon(Icons.add),
      label: const Text('EXERCÍCIO'),
    ),
    body: FutureBuilder<List<Map<String, dynamic>>>(
      future: _items,
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done)
          return const Center(child: CircularProgressIndicator());
        if (snapshot.hasError) return Center(child: Text('${snapshot.error}'));
        final items = snapshot.data ?? const [];
        return ListView(
          padding: const EdgeInsets.all(AppSpacing.lg),
          children: [
            const SectionHeading(
              'Catálogo de exercícios',
              eyebrow: 'Criar, renomear e excluir',
            ),
            const SizedBox(height: 12),
            ...items.map(
              (item) => Card(
                child: ListTile(
                  title: Text(item['name'].toString()),
                  subtitle: Text(item['category_name'].toString()),
                  trailing: PopupMenuButton<String>(
                    onSelected: (action) =>
                        action == 'rename' ? _rename(item) : _delete(item),
                    itemBuilder: (_) => const [
                      PopupMenuItem(value: 'rename', child: Text('Renomear')),
                      PopupMenuItem(value: 'delete', child: Text('Excluir')),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 80),
          ],
        );
      },
    ),
  );

  Future<void> _create() async {
    final categories = await LocalApi.instance.adminCategories();
    if (!mounted) return;
    final name = TextEditingController();
    String? category = categories.isEmpty
        ? null
        : categories.first['id'].toString();
    final accepted = await showDialog<bool>(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text('Novo exercício'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: name,
                decoration: const InputDecoration(labelText: 'Nome'),
              ),
              const SizedBox(height: 10),
              DropdownButtonFormField<String>(
                value: category,
                items: categories
                    .map(
                      (item) => DropdownMenuItem(
                        value: item['id'].toString(),
                        child: Text(item['name'].toString()),
                      ),
                    )
                    .toList(),
                onChanged: (value) => setDialogState(() => category = value),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('CANCELAR'),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('ADICIONAR'),
            ),
          ],
        ),
      ),
    );
    if (accepted != true || category == null) return;
    await LocalApi.instance.createAdminExercise(name.text.trim(), category!);
    setState(() => _items = LocalApi.instance.adminExercises());
    widget.onChanged();
  }

  Future<void> _rename(Map<String, dynamic> item) async {
    final controller = TextEditingController(text: item['name'].toString());
    final value = await _textDialog(context, 'Renomear exercício', controller);
    if (value == null) return;
    await LocalApi.instance.renameAdminExercise(item['id'].toString(), value);
    setState(() => _items = LocalApi.instance.adminExercises());
    widget.onChanged();
  }

  Future<void> _delete(Map<String, dynamic> item) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Excluir exercício?'),
        content: Text(item['name'].toString()),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('CANCELAR'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('EXCLUIR'),
          ),
        ],
      ),
    );
    if (confirmed != true) return;
    await LocalApi.instance.deleteAdminExercise(item['id'].toString());
    setState(() => _items = LocalApi.instance.adminExercises());
    widget.onChanged();
  }
}

class _AdminUsers extends StatefulWidget {
  const _AdminUsers({super.key, required this.onChanged});
  final VoidCallback onChanged;
  @override
  State<_AdminUsers> createState() => _AdminUsersState();
}

class _AdminUsersState extends State<_AdminUsers> {
  late Future<List<Map<String, dynamic>>> _items;
  @override
  void initState() {
    super.initState();
    _items = LocalApi.instance.adminUsers();
  }

  @override
  Widget build(
    BuildContext context,
  ) => FutureBuilder<List<Map<String, dynamic>>>(
    future: _items,
    builder: (context, snapshot) {
      if (snapshot.connectionState != ConnectionState.done)
        return const Center(child: CircularProgressIndicator());
      if (snapshot.hasError) return Center(child: Text('${snapshot.error}'));
      return ListView(
        padding: const EdgeInsets.all(AppSpacing.lg),
        children: [
          const SectionHeading(
            'Contas',
            eyebrow: 'Ativar, desativar e redefinir senha',
          ),
          const SizedBox(height: 12),
          ...(snapshot.data ?? const []).map(
            (item) => Card(
              child: ListTile(
                title: Text(item['display_name'].toString()),
                subtitle: Text('@${item['username']} · ${item['user_type']}'),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Switch(
                      value: item['is_active'] == true,
                      onChanged: (active) =>
                          _update(item, {'isActive': active}),
                    ),
                    PopupMenuButton<String>(
                      onSelected: (action) => _accountAction(item, action),
                      itemBuilder: (_) => [
                        PopupMenuItem(
                          value: 'role',
                          child: Text(
                            item['user_type'] == 'administrator'
                                ? 'Remover administração'
                                : 'Tornar administrador',
                          ),
                        ),
                        const PopupMenuItem(
                          value: 'password',
                          child: Text('Redefinir senha'),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      );
    },
  );

  Future<void> _update(
    Map<String, dynamic> item,
    Map<String, Object?> values,
  ) async {
    await LocalApi.instance.updateAdminUser(item['id'].toString(), values);
    if (!mounted) return;
    setState(() => _items = LocalApi.instance.adminUsers());
    widget.onChanged();
  }

  Future<void> _accountAction(Map<String, dynamic> item, String action) async {
    if (action == 'role') {
      await _update(item, {
        'userType': item['user_type'] == 'administrator'
            ? 'standard'
            : 'administrator',
      });
      return;
    }
    final password = await _textDialog(
      context,
      'Nova senha',
      TextEditingController(),
    );
    if (password == null || password.isEmpty) return;
    await _update(item, {'password': password});
  }
}

Future<String?> _textDialog(
  BuildContext context,
  String title,
  TextEditingController controller,
) => showDialog<String>(
  context: context,
  builder: (context) => AlertDialog(
    title: Text(title),
    content: TextField(controller: controller, autofocus: true),
    actions: [
      TextButton(
        onPressed: () => Navigator.pop(context),
        child: const Text('CANCELAR'),
      ),
      FilledButton(
        onPressed: () => Navigator.pop(context, controller.text.trim()),
        child: const Text('SALVAR'),
      ),
    ],
  ),
);
