import 'dart:io';

import 'package:limit_breaker_local_api/database/local_database_initializer.dart';

/// Cria o banco PostgreSQL local e aplica as migrações ainda pendentes.
Future<void> main() async {
  final databaseUrl = Platform.environment['DATABASE_URL'];
  if (databaseUrl == null || databaseUrl.isEmpty) {
    throw StateError('Defina DATABASE_URL antes de inicializar o banco.');
  }

  await LocalDatabaseInitializer.ensureCreated(databaseUrl);
  stdout.writeln('Banco local preparado para uso.');
}
