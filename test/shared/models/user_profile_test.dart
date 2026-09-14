import 'package:flutter_test/flutter_test.dart';
import 'package:limit_breaker/shared/models/models.dart';

void main() {
  test('converte o perfil retornado pela API local', () {
    final profile = UserProfile.fromJson({
      'id': 'perfil-1',
      'email': 'pessoa@example.com',
      'display_name': 'Pessoa Teste',
      'age': 30,
      'height_cm': 175.5,
      'weight_kg': 72,
      'created_at': '2026-09-14T12:00:00.000Z',
    });

    expect(profile.id, 'perfil-1');
    expect(profile.email, 'pessoa@example.com');
    expect(profile.displayName, 'Pessoa Teste');
    expect(profile.age, 30);
    expect(profile.heightCm, 175.5);
    expect(profile.weightKg, 72);
    expect(profile.createdAt, DateTime.utc(2026, 9, 14, 12));
  });
}
