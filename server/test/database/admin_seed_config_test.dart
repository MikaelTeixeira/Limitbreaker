import 'package:limit_breaker_local_api/database/admin_seed.dart';
import 'package:test/test.dart';

/// Valida a configuração local antes de qualquer conexão com o PostgreSQL.
void main() {
  test('ignora o seed quando nenhum administrador foi configurado', () {
    expect(AdminSeedConfig.fromEnvironment(const {}), isNull);
  });

  test('aceita promover uma conta existente apenas pelo nome de usuário', () {
    final config = AdminSeedConfig.fromEnvironment(const {
      'ADMIN_USERNAME': 'mikael.teixeira',
    });

    expect(config, isNotNull);
    expect(config!.username, 'mikael.teixeira');
    expect(config.resetPassword, isFalse);
  });

  test('exige os dados básicos ao criar uma conta nova', () {
    final config = AdminSeedConfig.fromEnvironment(const {
      'ADMIN_USERNAME': 'admin.local',
    });

    expect(config!.validateForNewAccount, throwsA(isA<StateError>()));
  });

  test('valida uma conta nova completa e a senha de redefinição', () {
    final config = AdminSeedConfig.fromEnvironment(const {
      'ADMIN_USERNAME': 'admin.local',
      'ADMIN_DISPLAY_NAME': 'Admin Local',
      'ADMIN_EMAIL': 'admin@example.com',
      'ADMIN_PASSWORD': 'senha-local-segura',
      'ADMIN_AGE': '23',
      'ADMIN_HEIGHT_CM': '170',
      'ADMIN_WEIGHT_KG': '70',
      'ADMIN_RESET_PASSWORD': 'true',
    });

    expect(config, isNotNull);
    expect(config!.validateForNewAccount, returnsNormally);
    expect(config.requirePassword(), 'senha-local-segura');
    expect(config.resetPassword, isTrue);
  });
}
