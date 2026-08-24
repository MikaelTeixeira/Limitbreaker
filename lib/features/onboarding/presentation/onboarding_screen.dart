import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/theme/app_theme.dart';
import '../../../shared/data/local_api.dart';
import '../../../shared/models/models.dart';
import '../../../shared/repositories/repositories.dart';
import 'sport_priority_carousel.dart';

class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({super.key});
  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen> {
  final _pageController = PageController();
  final _formKey = GlobalKey<FormState>();
  final _name = TextEditingController();
  final _email = TextEditingController();
  final _username = TextEditingController();
  final _password = TextEditingController();
  final _age = TextEditingController();
  final _height = TextEditingController();
  final _weight = TextEditingController();
  var _page = 0;
  UserGoal? _goal;
  String? _health;
  String? _family;
  String? _limitation;
  var _sports = List<SportType?>.filled(3, null);
  var _consent = false;

  static const _goalLabels = {
    UserGoal.gainMuscle: 'Ganhar massa muscular',
    UserGoal.loseFat: 'Perder gordura',
    UserGoal.conditioning: 'Melhorar condicionamento',
    UserGoal.sportsPerformance: 'Melhorar desempenho esportivo',
    UserGoal.health: 'Melhorar saúde',
    UserGoal.maintainFitness: 'Manter a forma',
  };

  @override
  void dispose() {
    _pageController.dispose();
    _name.dispose();
    _email.dispose();
    _username.dispose();
    _password.dispose();
    _age.dispose();
    _height.dispose();
    _weight.dispose();
    super.dispose();
  }

  bool _validCurrent() {
    if (_page == 0 && !(_formKey.currentState?.validate() ?? false)) {
      return false;
    }
    if (_page == 1 && _goal == null) {
      _message('Escolha seu objetivo principal.');
      return false;
    }
    if (_page == 2 && _sports.any((sport) => sport == null)) {
      _message('Defina as três modalidades para o Ranking.');
      return false;
    }
    if (_page == 3 && _health == null) {
      _message('Selecione uma resposta provisória.');
      return false;
    }
    if (_page == 4 && _family == null) {
      _message('Selecione uma resposta provisória.');
      return false;
    }
    if (_page == 5 && _limitation == null) {
      _message('Informe se existe alguma limitação.');
      return false;
    }
    if (_page == 6 && !_consent) {
      _message('O aceite é necessário para continuar.');
      return false;
    }
    return true;
  }

  void _message(String value) => ScaffoldMessenger.of(
    context,
  ).showSnackBar(SnackBar(content: Text(value)));
  Future<void> _next() async {
    if (!_validCurrent()) return;
    if (_page < 6) {
      await _pageController.nextPage(
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeOut,
      );
    } else {
      try {
        await LocalApi.instance.register(
          username: _username.text.trim(),
          email: _email.text.trim(),
          displayName: _name.text.trim(),
          password: _password.text,
          age: int.parse(_age.text),
          heightCm: double.parse(_height.text.replaceAll(',', '.')),
          weightKg: double.parse(_weight.text.replaceAll(',', '.')),
        );
      } on LocalApiException catch (error) {
        _message(error.message);
        return;
      } on FormatException {
        _message('Confira idade, altura e peso.');
        return;
      }
      await ref.read(onboardingRepositoryProvider).complete();
      if (mounted) context.go('/home');
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(
      backgroundColor: Colors.transparent,
      leading: _page == 0
          ? null
          : IconButton(
              tooltip: 'Voltar',
              onPressed: () => _pageController.previousPage(
                duration: const Duration(milliseconds: 220),
                curve: Curves.easeOut,
              ),
              icon: const Icon(Icons.arrow_back),
            ),
      title: Text(
        'ETAPA ${_page + 1} / 7',
        style: Theme.of(context).textTheme.labelSmall,
      ),
      actions: [TextButton(onPressed: _confirmExit, child: const Text('SAIR'))],
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(2),
        child: LinearProgressIndicator(
          value: (_page + 1) / 7,
          minHeight: 2,
          backgroundColor: AppColors.graphite,
          color: AppColors.frost,
        ),
      ),
    ),
    body: SafeArea(
      child: Column(
        children: [
          Expanded(
            child: PageView(
              controller: _pageController,
              physics: const NeverScrollableScrollPhysics(),
              onPageChanged: (value) => setState(() => _page = value),
              children: [
                _Step(
                  title: 'VAMOS COMEÇAR\nSUA JORNADA.',
                  subtitle:
                      'Crie seu acesso e preencha seus dados básicos uma única vez.',
                  child: Form(
                    key: _formKey,
                    child: Column(
                      children: [
                        TextFormField(
                          controller: _name,
                          textCapitalization: TextCapitalization.words,
                          decoration: const InputDecoration(
                            labelText: 'Nome de exibição',
                          ),
                          validator: (value) =>
                              value == null || value.trim().length < 2
                              ? 'Informe pelo menos 2 caracteres.'
                              : null,
                        ),
                        const SizedBox(height: 10),
                        TextFormField(
                          controller: _email,
                          keyboardType: TextInputType.emailAddress,
                          autofillHints: const [AutofillHints.email],
                          decoration: const InputDecoration(
                            labelText: 'E-mail',
                            hintText: 'voce@exemplo.com',
                          ),
                          validator: _emailValidator,
                        ),
                        const SizedBox(height: 10),
                        TextFormField(
                          controller: _username,
                          decoration: const InputDecoration(
                            labelText: 'Nome de usuário',
                          ),
                          validator: (value) =>
                              value == null || value.trim().length < 3
                              ? 'Informe pelo menos 3 caracteres.'
                              : null,
                        ),
                        const SizedBox(height: 10),
                        TextFormField(
                          controller: _password,
                          obscureText: true,
                          decoration: const InputDecoration(
                            labelText: 'Senha',
                            hintText: 'Mínimo de 8 caracteres',
                          ),
                          validator: (value) =>
                              value == null || value.length < 8
                              ? 'A senha deve ter ao menos 8 caracteres.'
                              : null,
                        ),
                        const SizedBox(height: 10),
                        Row(
                          children: [
                            Expanded(
                              child: TextFormField(
                                controller: _age,
                                keyboardType: TextInputType.number,
                                decoration: const InputDecoration(
                                  labelText: 'Idade',
                                ),
                                validator: _positive,
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: TextFormField(
                                controller: _height,
                                keyboardType: TextInputType.number,
                                decoration: const InputDecoration(
                                  labelText: 'Altura (cm)',
                                ),
                                validator: _positive,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        TextFormField(
                          controller: _weight,
                          keyboardType: TextInputType.number,
                          decoration: const InputDecoration(
                            labelText: 'Peso (kg)',
                          ),
                          validator: _positive,
                        ),
                      ],
                    ),
                  ),
                ),
                _Step(
                  title: 'QUAL É O SEU\nPRINCIPAL OBJETIVO?',
                  subtitle: 'Isso ajuda a personalizar seu ponto de partida.',
                  child: Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: _goalLabels.entries
                        .map(
                          (entry) => ChoiceChip(
                            label: Text(entry.value),
                            selected: _goal == entry.key,
                            onSelected: (_) =>
                                setState(() => _goal = entry.key),
                          ),
                        )
                        .toList(),
                  ),
                ),
                _Step(
                  title: 'SELECIONE SUAS\nMODALIDADES.',
                  subtitle:
                      'Deslize para escolher. O Ranking usará 75% da modalidade primária, 15% da secundária e 10% da terciária.',
                  child: SportPriorityCarousel(
                    selection: _sports,
                    onChanged: (selection) =>
                        setState(() => _sports = selection),
                  ),
                ),
                _ChoiceStep(
                  title: 'SAÚDE GERAL',
                  subtitle:
                      'Pergunta demonstrativa — critérios oficiais pendentes. Não é diagnóstico.',
                  value: _health,
                  onChanged: (value) => setState(() => _health = value),
                ),
                _ChoiceStep(
                  title: 'HISTÓRICO FAMILIAR',
                  subtitle:
                      'Pergunta demonstrativa. As respostas serão tratadas como dados sensíveis.',
                  value: _family,
                  onChanged: (value) => setState(() => _family = value),
                ),
                _ChoiceStep(
                  title: 'LIMITAÇÕES FÍSICAS',
                  subtitle:
                      'O aplicativo não substitui acompanhamento médico ou profissional.',
                  value: _limitation,
                  labels: const ['Não possuo', 'Possuo — informar depois'],
                  onChanged: (value) => setState(() => _limitation = value),
                ),
                _Step(
                  title: 'TERMOS E\nCONSENTIMENTO',
                  subtitle:
                      'Documentos jurídicos provisórios — revisão legal pendente.',
                  child: CheckboxListTile(
                    contentPadding: EdgeInsets.zero,
                    value: _consent,
                    onChanged: (value) =>
                        setState(() => _consent = value ?? false),
                    title: const Text(
                      'Li e aceito os termos, a política de privacidade e o tratamento de dados.',
                    ),
                    subtitle: const Text(
                      'Versão demonstrativa 0.1. O app não substitui acompanhamento profissional.',
                    ),
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: FilledButton(
              onPressed: _next,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(_page == 6 ? 'CONCLUIR' : 'CONTINUAR'),
                  const Icon(Icons.arrow_forward),
                ],
              ),
            ),
          ),
        ],
      ),
    ),
  );

  Future<void> _confirmExit() async {
    final shouldExit = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Sair do cadastro?'),
        content: const Text('As informações desta etapa não serão salvas.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('CONTINUAR'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('SAIR'),
          ),
        ],
      ),
    );
    if (shouldExit == true && mounted) context.go('/login');
  }
}

String? _positive(String? value) =>
    double.tryParse((value ?? '').replaceAll(',', '.')) == null ||
        double.parse((value ?? '').replaceAll(',', '.')) <= 0
    ? 'Informe um valor válido.'
    : null;

String? _emailValidator(String? value) {
  final email = value?.trim() ?? '';
  return RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]+$').hasMatch(email)
      ? null
      : 'Informe um e-mail válido.';
}

class _Step extends StatefulWidget {
  const _Step({
    required this.title,
    required this.subtitle,
    required this.child,
  });
  final String title;
  final String subtitle;
  final Widget child;

  @override
  State<_Step> createState() => _StepState();
}

class _StepState extends State<_Step> {
  final _scrollController = ScrollController();
  var _canScrollDown = false;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_updateScrollState);
    WidgetsBinding.instance.addPostFrameCallback((_) => _updateScrollState());
  }

  void _updateScrollState() {
    if (!_scrollController.hasClients) return;
    final canScroll =
        _scrollController.position.pixels <
        _scrollController.position.maxScrollExtent - 8;
    if (canScroll != _canScrollDown && mounted) {
      setState(() => _canScrollDown = canScroll);
    }
  }

  @override
  void dispose() {
    _scrollController
      ..removeListener(_updateScrollState)
      ..dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Stack(
    children: [
      SingleChildScrollView(
        controller: _scrollController,
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 18),
            Text(
              widget.title,
              style: Theme.of(context).textTheme.displayMedium,
            ),
            const SizedBox(height: 10),
            Text(widget.subtitle),
            const SizedBox(height: 28),
            widget.child,
            const SizedBox(height: 80),
          ],
        ),
      ),
      if (_canScrollDown)
        Positioned(
          right: AppSpacing.lg,
          bottom: AppSpacing.lg,
          child: FloatingActionButton.small(
            tooltip: 'Ir para o fim da página',
            onPressed: () => _scrollController.animateTo(
              _scrollController.position.maxScrollExtent,
              duration: const Duration(milliseconds: 260),
              curve: Curves.easeOut,
            ),
            child: const Icon(Icons.keyboard_arrow_down),
          ),
        ),
    ],
  );
}

class _ChoiceStep extends StatelessWidget {
  const _ChoiceStep({
    required this.title,
    required this.subtitle,
    required this.value,
    required this.onChanged,
    this.labels = const [
      'Nenhuma condição relevante informada',
      'Prefiro revisar depois',
    ],
  });
  final String title;
  final String subtitle;
  final String? value;
  final ValueChanged<String?> onChanged;
  final List<String> labels;
  @override
  Widget build(BuildContext context) => _Step(
    title: title,
    subtitle: subtitle,
    child: Column(
      children: labels.map((label) {
        final selected = value == label;
        return Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: Card(
            color: selected ? AppColors.graphite : null,
            child: ListTile(
              minTileHeight: 58,
              onTap: () => onChanged(label),
              leading: Icon(
                selected ? Icons.radio_button_checked : Icons.radio_button_off,
                color: selected ? AppColors.frost : AppColors.steel,
              ),
              title: Text(label),
            ),
          ),
        );
      }).toList(),
    ),
  );
}
