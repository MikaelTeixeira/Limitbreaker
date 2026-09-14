import 'package:bcrypt/bcrypt.dart';
import 'package:limit_breaker_local_api/database/local_database_initializer.dart';
import 'package:postgres/postgres.dart';

/// Configura a conta administrativa opcional criada no banco local.
class AdminSeedConfig {
  /// Cria a configuração usando variáveis de ambiente já validadas.
  const AdminSeedConfig._({
    required this.username,
    required this.displayName,
    required this.email,
    required this.password,
    required this.age,
    required this.heightCm,
    required this.weightKg,
    required this.resetPassword,
  });

  /// Lê a configuração opcional do administrador a partir do ambiente local.
  static AdminSeedConfig? fromEnvironment(Map<String, String> environment) {
    final username = _optionalText(environment, 'ADMIN_USERNAME');
    if (username == null) return null;

    return AdminSeedConfig._(
      username: _validateText('ADMIN_USERNAME', username, 3, 30).toLowerCase(),
      displayName: _optionalText(environment, 'ADMIN_DISPLAY_NAME'),
      email: _optionalText(environment, 'ADMIN_EMAIL')?.toLowerCase(),
      password: _optionalText(environment, 'ADMIN_PASSWORD'),
      age: _optionalInt(environment, 'ADMIN_AGE'),
      heightCm: _optionalNumber(environment, 'ADMIN_HEIGHT_CM'),
      weightKg: _optionalNumber(environment, 'ADMIN_WEIGHT_KG'),
      resetPassword: _optionalBoolean(environment, 'ADMIN_RESET_PASSWORD'),
    );
  }

  /// Nome de usuário usado para localizar ou criar a conta administradora.
  final String username;

  /// Nome de exibição usado apenas ao criar uma conta nova.
  final String? displayName;

  /// E-mail usado apenas ao criar uma conta nova ou detectar conflito de conta.
  final String? email;

  /// Senha usada ao criar uma conta ou redefini-la explicitamente.
  final String? password;

  /// Idade inicial exigida pelo perfil físico de uma conta nova.
  final int? age;

  /// Altura inicial em centímetros exigida pelo perfil físico de uma conta nova.
  final double? heightCm;

  /// Peso inicial em quilogramas exigido pelo perfil físico de uma conta nova.
  final double? weightKg;

  /// Define se uma conta existente deve receber uma nova senha configurada.
  final bool resetPassword;

  /// Confirma que há dados suficientes para criar uma conta do zero.
  void validateForNewAccount() {
    _validateText('ADMIN_DISPLAY_NAME', displayName, 2, 50);
    final configuredEmail = _validateText('ADMIN_EMAIL', email, 5, 320);
    if (!configuredEmail.contains('@')) {
      throw FormatException('ADMIN_EMAIL deve conter @.');
    }
    requirePassword();
    _validateRange('ADMIN_AGE', age, 13, 120);
    _validateRange('ADMIN_HEIGHT_CM', heightCm, 80, 250);
    _validateRange('ADMIN_WEIGHT_KG', weightKg, 20, 400);
  }

  /// Retorna a senha válida quando a operação precisa gravar um novo hash.
  String requirePassword() => _validateText('ADMIN_PASSWORD', password, 8, 128);

  /// Lê um texto opcional sem espaços extras da configuração local.
  static String? _optionalText(Map<String, String> environment, String name) {
    final value = environment[name]?.trim();
    return value == null || value.isEmpty ? null : value;
  }

  /// Converte um número inteiro opcional ou explica a configuração inválida.
  static int? _optionalInt(Map<String, String> environment, String name) {
    final text = _optionalText(environment, name);
    if (text == null) return null;
    final value = int.tryParse(text);
    if (value == null) {
      throw FormatException('$name deve ser um número inteiro.');
    }
    return value;
  }

  /// Converte um número decimal opcional ou explica a configuração inválida.
  static double? _optionalNumber(Map<String, String> environment, String name) {
    final text = _optionalText(environment, name);
    if (text == null) return null;
    final value = double.tryParse(text);
    if (value == null) {
      throw FormatException('$name deve ser um número decimal.');
    }
    return value;
  }

  /// Converte a opção explícita de redefinição de senha para valor booleano.
  static bool _optionalBoolean(Map<String, String> environment, String name) {
    final text = _optionalText(environment, name);
    if (text == null || text.toLowerCase() == 'false') return false;
    if (text.toLowerCase() == 'true') return true;
    throw FormatException('$name deve ser true ou false.');
  }

  /// Exige um texto configurado dentro dos limites aceitos pelo banco local.
  static String _validateText(String name, String? value, int min, int max) {
    if (value == null || value.length < min || value.length > max) {
      throw StateError('$name deve ter entre $min e $max caracteres.');
    }
    return value;
  }

  /// Exige um número configurado dentro dos limites aceitos pelo banco local.
  static void _validateRange(String name, num? value, num min, num max) {
    if (value == null || value < min || value > max) {
      throw StateError('$name deve estar entre $min e $max.');
    }
  }
}

/// Indica se o seed criou uma conta ou promoveu uma conta já existente.
enum AdminSeedAction {
  /// Uma conta existente foi ativada e recebeu o papel administrativo.
  promotedExistingAccount,

  /// Uma nova conta administrativa foi criada com os dados configurados.
  createdAccount,
}

/// Cria ou promove a conta administrativa configurada para o ambiente local.
class LocalAdminSeeder {
  /// Impede instâncias porque o seed oferece apenas uma operação estática.
  LocalAdminSeeder._();

  /// Prepara o banco e garante uma conta administradora ativa e idempotente.
  static Future<AdminSeedAction> ensureAdmin(
    String databaseUrl,
    AdminSeedConfig config,
  ) async {
    await LocalDatabaseInitializer.ensureCreated(databaseUrl);
    final connection = await _open(databaseUrl);
    try {
      final accounts = await _findMatchingAccounts(connection, config);
      if (accounts.length > 1) {
        throw StateError(
          'ADMIN_USERNAME e ADMIN_EMAIL apontam para contas diferentes.',
        );
      }
      if (accounts.isNotEmpty) {
        await _promoteExistingAccount(connection, accounts.first, config);
        return AdminSeedAction.promotedExistingAccount;
      }

      config.validateForNewAccount();
      await _createAccount(connection, config);
      return AdminSeedAction.createdAccount;
    } finally {
      await connection.close();
    }
  }

  /// Abre uma conexão local sem exigir SSL durante o desenvolvimento.
  static Future<Connection> _open(String databaseUrl) => Connection.openFromUrl(
    databaseUrl.contains('?')
        ? '$databaseUrl&sslmode=disable'
        : '$databaseUrl?sslmode=disable',
  );

  /// Procura contas pelo nome de usuário e, quando disponível, pelo e-mail.
  static Future<Result> _findMatchingAccounts(
    Connection connection,
    AdminSeedConfig config,
  ) {
    final hasEmail = config.email != null;
    final query = hasEmail
        ? '''
            select u.id::text as id
            from users u
            left join app_profiles p on p.id = u.profile_id
            where lower(u.username) = @username or lower(p.email) = @email
          '''
        : 'select id::text as id from users where lower(username) = @username';
    return connection.execute(
      Sql.named(query),
      parameters: {
        'username': config.username,
        if (hasEmail) 'email': config.email,
      },
    );
  }

  /// Ativa uma conta localizada, promove seu papel e redefine senha se solicitado.
  static Future<void> _promoteExistingAccount(
    Connection connection,
    ResultRow account,
    AdminSeedConfig config,
  ) async {
    final parameters = <String, Object?>{'id': account.toColumnMap()['id']};
    var update =
        "update users set user_type = 'administrator', is_active = true";
    if (config.resetPassword) {
      parameters['passwordHash'] = BCrypt.hashpw(
        config.requirePassword(),
        BCrypt.gensalt(),
      );
      update += ', password_hash = @passwordHash';
    }
    await connection.execute(
      Sql.named('$update where id = @id'),
      parameters: parameters,
    );
  }

  /// Cria o perfil básico e a conta administrativa em uma única transação.
  static Future<void> _createAccount(
    Connection connection,
    AdminSeedConfig config,
  ) async {
    await connection.runTx((transaction) async {
      final profile = await transaction.execute(
        Sql.named(
          'insert into app_profiles (email, display_name, age, height_cm, weight_kg) values (@email, @displayName, @age, @heightCm, @weightKg) returning id',
        ),
        parameters: {
          'email': config.email,
          'displayName': config.displayName,
          'age': config.age,
          'heightCm': config.heightCm,
          'weightKg': config.weightKg,
        },
      );
      await transaction.execute(
        Sql.named(
          "insert into users (profile_id, username, display_name, password_hash, user_type, is_active) values (@profileId, @username, @displayName, @passwordHash, 'administrator', true)",
        ),
        parameters: {
          'profileId': profile.first[0],
          'username': config.username,
          'displayName': config.displayName,
          'passwordHash': BCrypt.hashpw(
            config.requirePassword(),
            BCrypt.gensalt(),
          ),
        },
      );
    });
  }
}
