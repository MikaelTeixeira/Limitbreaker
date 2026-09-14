import 'package:flutter_test/flutter_test.dart';
import 'package:limit_breaker/features/activities/domain/personal_record_calculator.dart';
import 'package:limit_breaker/shared/models/models.dart';

void main() {
  const calculator = PersonalRecordCalculator();

  test('calcula distância e melhor pace de corrida', () {
    final records = calculator.calculate([
      _activity('a', 'running', 5, 30),
      _activity('b', 'running', 10, 70),
    ]);

    expect(records.map((item) => item.label), [
      'Maior corrida',
      'Melhor pace na corrida',
    ]);
    expect(records[0].value, 10);
    expect(records[1].value, 360);
  });

  test('calcula recordes de ciclismo e natação nas unidades corretas', () {
    final records = calculator.calculate([
      _activity('bike', 'cycling', 20, 60),
      _activity('swim', 'swimming', 1, 20),
    ]);

    expect(records.map((item) => item.unit), ['km', 'km/h', 'm', 's/100m']);
    expect(records[1].value, 20);
    expect(records[2].value, 1000);
    expect(records[3].value, 120);
  });

  test('ignora atividades inválidas e musculação', () {
    final records = calculator.calculate([
      _activity('strength', 'strength', 1, 10),
      _activity('invalid', 'running', 0, 10),
    ]);

    expect(records, isEmpty);
  });
}

ActivitySession _activity(
  String id,
  String category,
  double distanceKm,
  int minutes,
) => ActivitySession(
  id: id,
  categoryId: category,
  performedAt: DateTime.utc(2026, 9, 14),
  distanceKm: distanceKm,
  duration: Duration(minutes: minutes),
);
