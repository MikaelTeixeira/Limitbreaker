import 'dart:io';

import 'package:postgres/postgres.dart';

/// Prepara o PostgreSQL local usado pela API de desenvolvimento.
///
/// A classe cria o banco indicado na URL, quando necessário, e aplica cada
/// migração uma única vez. O usuário do PostgreSQL precisa da permissão
/// `CREATEDB` apenas na primeira execução em uma máquina nova.
class LocalDatabaseInitializer {
  /// Impede instâncias, pois a classe oferece apenas operações estáticas.
  LocalDatabaseInitializer._();

  static const _migrationFiles = [
    '202608100001_initial_local_schema.sql',
    '202608110001_local_credentials.sql',
    '202608110002_workout_persistence.sql',
    '202608170001_exercise_catalog.sql',
    '202608170002_users.sql',
    '202608170003_admin_access.sql',
  ];

  /// Cria o banco e aplica as migrações pendentes para a URL informada.
  static Future<void> ensureCreated(String databaseUrl) async {
    final databaseName = _databaseName(databaseUrl);
    await _createDatabaseWhenMissing(databaseUrl, databaseName);

    final connection = await _open(databaseUrl);
    try {
      await connection.execute('''
        create table if not exists schema_migrations (
          filename text primary key,
          applied_at timestamptz not null default now()
        )
      ''');
      await _applyPendingMigrations(connection);
    } finally {
      await connection.close();
    }
  }

  /// Conecta ao banco administrativo e cria o banco da aplicação se faltar.
  static Future<void> _createDatabaseWhenMissing(
    String databaseUrl,
    String databaseName,
  ) async {
    final administrationUrl = _withDatabase(databaseUrl, 'postgres');
    final connection = await _open(administrationUrl);
    try {
      final result = await connection.execute(
        Sql.named('select 1 from pg_database where datname = @name'),
        parameters: {'name': databaseName},
      );
      if (result.isEmpty) {
        await connection.execute('create database "$databaseName"');
        stdout.writeln('Banco local "$databaseName" criado.');
      }
    } finally {
      await connection.close();
    }
  }

  /// Executa cada arquivo de migração que ainda não foi registrado no banco.
  static Future<void> _applyPendingMigrations(Connection connection) async {
    final migrationsDirectory = File.fromUri(
      Platform.script,
    ).parent.parent.parent.uri.resolve('database/migrations/');

    for (final filename in _migrationFiles) {
      final alreadyApplied = await connection.execute(
        Sql.named('select 1 from schema_migrations where filename = @filename'),
        parameters: {'filename': filename},
      );
      if (alreadyApplied.isNotEmpty) continue;

      final migration = File.fromUri(migrationsDirectory.resolve(filename));
      if (!await migration.exists()) {
        throw StateError('Migração não encontrada: ${migration.path}');
      }

      await connection.runTx((transaction) async {
        for (final statement in _sqlStatements(
          await migration.readAsString(),
        )) {
          await transaction.execute(statement);
        }
        await transaction.execute(
          Sql.named(
            'insert into schema_migrations (filename) values (@filename)',
          ),
          parameters: {'filename': filename},
        );
      });
      stdout.writeln('Migração aplicada: $filename');
    }
  }

  /// Abre uma conexão local sem exigir SSL durante o desenvolvimento.
  static Future<Connection> _open(String url) => Connection.openFromUrl(
    url.contains('?') ? '$url&sslmode=disable' : '$url?sslmode=disable',
  );

  /// Separa comandos SQL sem dividir ponto e vírgula dentro de textos.
  static Iterable<String> _sqlStatements(String source) sync* {
    final statement = StringBuffer();
    var insideText = false;

    for (var index = 0; index < source.length; index++) {
      final character = source[index];
      statement.write(character);

      if (character == "'") {
        final isEscapedQuote =
            insideText && index + 1 < source.length && source[index + 1] == "'";
        if (isEscapedQuote) {
          statement.write(source[++index]);
        } else {
          insideText = !insideText;
        }
      }

      if (character == ';' && !insideText) {
        final sql = statement.toString().trim();
        if (sql.isNotEmpty) yield sql;
        statement.clear();
      }
    }

    final remaining = statement.toString().trim();
    if (remaining.isNotEmpty) yield remaining;
  }

  /// Extrai e valida o nome do banco presente na URL de conexão.
  static String _databaseName(String databaseUrl) {
    final name = Uri.parse(databaseUrl).pathSegments.last;
    if (!RegExp(r'^[A-Za-z0-9_]+$').hasMatch(name)) {
      throw FormatException('Nome de banco inválido: $name');
    }
    return name;
  }

  /// Troca o banco da URL, preservando host, credenciais e parâmetros.
  static String _withDatabase(String databaseUrl, String databaseName) {
    final uri = Uri.parse(databaseUrl);
    return uri.replace(path: '/$databaseName').toString();
  }
}
