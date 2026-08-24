import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../app/theme/app_theme.dart';
import '../../../core/widgets/brand_widgets.dart';
import '../../../shared/data/local_api.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _identifier = TextEditingController();
  final _password = TextEditingController();
  var _obscurePassword = true;
  var _saving = false;

  @override
  void dispose() {
    _identifier.dispose();
    _password.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    body: SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const BrandMark(compact: true),
            const Spacer(),
            Text(
              'ENTRE NO\nLIMIT BREAKER',
              style: Theme.of(context).textTheme.displayMedium,
            ),
            const SizedBox(height: 12),
            const Text('Use seu nome de usuário ou e-mail e sua senha.'),
            const SizedBox(height: 20),
            TextField(
              controller: _identifier,
              decoration: const InputDecoration(
                labelText: 'Nome de usuário ou e-mail',
              ),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: _password,
              obscureText: _obscurePassword,
              decoration: InputDecoration(
                labelText: 'Senha',
                suffixIcon: IconButton(
                  tooltip: _obscurePassword ? 'Mostrar senha' : 'Ocultar senha',
                  icon: Icon(
                    _obscurePassword ? Icons.visibility : Icons.visibility_off,
                  ),
                  onPressed: () =>
                      setState(() => _obscurePassword = !_obscurePassword),
                ),
              ),
            ),
            const SizedBox(height: 16),
            FilledButton(
              onPressed: _saving
                  ? null
                  : () async {
                      if (_identifier.text.trim().isEmpty ||
                          _password.text.isEmpty) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Informe usuário/e-mail e senha.'),
                          ),
                        );
                        return;
                      }
                      setState(() => _saving = true);
                      try {
                        final isAdministrator = await LocalApi.instance.login(
                          _identifier.text.trim(),
                          _password.text,
                        );
                        if (mounted)
                          context.go(isAdministrator ? '/admin' : '/home');
                      } on LocalApiException catch (error) {
                        if (mounted)
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text(error.message)),
                          );
                      } finally {
                        if (mounted) setState(() => _saving = false);
                      }
                    },
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [Text('ENTRAR'), Icon(Icons.login)],
              ),
            ),
            TextButton(
              onPressed: () => context.go('/register'),
              child: const Text('AINDA NÃO TEM CONTA? CRIAR PERFIL'),
            ),
            OutlinedButton.icon(
              onPressed: null,
              icon: const Icon(Icons.g_mobiledata),
              label: const Text('CONTINUAR COM GOOGLE — EM BREVE'),
            ),
            const Spacer(),
          ],
        ),
      ),
    ),
  );
}

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});
  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _username = TextEditingController();
  final _email = TextEditingController();
  final _name = TextEditingController();
  final _password = TextEditingController();
  final _age = TextEditingController();
  final _height = TextEditingController();
  final _weight = TextEditingController();
  var _saving = false;
  @override
  void dispose() {
    for (final c in [
      _username,
      _email,
      _name,
      _password,
      _age,
      _height,
      _weight,
    ]) {
      c.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(),
    body: SafeArea(
      child: ListView(
        keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
        padding: const EdgeInsets.all(AppSpacing.lg),
        children: [
          Text(
            'CRIE SEU\nPONTO DE PARTIDA.',
            style: Theme.of(context).textTheme.displayMedium,
          ),
          const SizedBox(height: 12),
          const Text(
            'Crie a conta local. As preferências de treino são preenchidas no onboarding em seguida.',
          ),
          const SizedBox(height: 22),
          const _FormLabel('IDENTIFICAÇÃO'),
          const SizedBox(height: 8),
          TextField(
            controller: _name,
            textCapitalization: TextCapitalization.words,
            decoration: const InputDecoration(labelText: 'Nome completo'),
          ),
          const SizedBox(height: 10),
          TextField(
            controller: _email,
            keyboardType: TextInputType.emailAddress,
            decoration: const InputDecoration(labelText: 'E-mail'),
          ),
          const SizedBox(height: 22),
          const _FormLabel('ACESSO'),
          const SizedBox(height: 8),
          TextField(
            controller: _username,
            decoration: const InputDecoration(labelText: 'Nome de usuário'),
          ),
          const SizedBox(height: 10),
          TextField(
            controller: _password,
            obscureText: true,
            decoration: const InputDecoration(
              labelText: 'Senha',
              hintText: 'Mínimo de 8 caracteres',
            ),
          ),
          const SizedBox(height: 22),
          const _FormLabel('MEDIDAS'),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: _MeasureField(controller: _age, label: 'Idade'),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _MeasureField(controller: _height, label: 'Altura (cm)'),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _MeasureField(controller: _weight, label: 'Peso (kg)'),
              ),
            ],
          ),
          const SizedBox(height: 16),
          FilledButton(
            onPressed: _saving
                ? null
                : () async {
                    setState(() => _saving = true);
                    try {
                      await LocalApi.instance.register(
                        username: _username.text.trim(),
                        email: _email.text.trim(),
                        displayName: _name.text.trim(),
                        password: _password.text,
                        age: int.parse(_age.text),
                        heightCm: double.parse(
                          _height.text.replaceAll(',', '.'),
                        ),
                        weightKg: double.parse(
                          _weight.text.replaceAll(',', '.'),
                        ),
                      );
                      if (mounted) context.go('/onboarding');
                    } on FormatException {
                      if (mounted)
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Confira idade, altura e peso.'),
                          ),
                        );
                    } on LocalApiException catch (error) {
                      if (mounted)
                        ScaffoldMessenger.of(
                          context,
                        ).showSnackBar(SnackBar(content: Text(error.message)));
                    } finally {
                      if (mounted) setState(() => _saving = false);
                    }
                  },
            child: const Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [Text('COMEÇAR CADASTRO'), Icon(Icons.arrow_forward)],
            ),
          ),
          const SizedBox(height: AppSpacing.xl),
        ],
      ),
    ),
  );
}

class _FormLabel extends StatelessWidget {
  const _FormLabel(this.text);
  final String text;

  @override
  Widget build(BuildContext context) =>
      Text(text, style: Theme.of(context).textTheme.labelSmall);
}

class _MeasureField extends StatelessWidget {
  const _MeasureField({required this.controller, required this.label});
  final TextEditingController controller;
  final String label;

  @override
  Widget build(BuildContext context) => TextField(
    controller: controller,
    keyboardType: TextInputType.number,
    decoration: InputDecoration(labelText: label),
  );
}
