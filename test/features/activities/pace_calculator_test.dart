import 'package:flutter_test/flutter_test.dart';
import 'package:limit_breaker/features/activities/domain/pace_calculator.dart';

void main() {
  test('calcula pace de corrida por quilômetro', () {
    expect(
      PaceCalculator.format(
        categoryId: 'running',
        duration: const Duration(minutes: 25),
        distanceKm: 5,
      ),
      '5:00 /km',
    );
  });

  test('calcula pace de natação por 100 metros', () {
    expect(
      PaceCalculator.format(
        categoryId: 'swimming',
        duration: const Duration(minutes: 20),
        distanceKm: 1,
      ),
      '2:00 /100 m',
    );
  });
}
