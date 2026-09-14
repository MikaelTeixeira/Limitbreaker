import 'dart:io';

import 'package:limit_breaker_local_api/database/admin_seed.dart';

/// Cria ou promove a conta administrativa configurada no ambiente local.
Future<void> main() async {
  final databaseUrl = Platform.environment['DATABASE_URL'];
  if (databaseUrl == null || databaseUrl.isEmpty) {
    throw StateError('Defina DATABASE_URL antes de preparar o administrador.');
  }

  final config = AdminSeedConfig.fromEnvironment(Platform.environment);
  if (config == null) {
    stdout.writeln(
      'Seed administrativo ignorado: ADMIN_USERNAME não definido.',
    );
    return;
  }

  final action = await LocalAdminSeeder.ensureAdmin(databaseUrl, config);
  switch (action) {
    case AdminSeedAction.promotedExistingAccount:
      stdout.writeln('Conta administrativa local preparada.');
    case AdminSeedAction.createdAccount:
      stdout.writeln('Conta administrativa local criada.');
  }
}
