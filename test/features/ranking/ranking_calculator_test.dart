import 'package:flutter_test/flutter_test.dart';
import 'package:limit_breaker/features/ranking/domain/ranking_calculator.dart';
import 'package:limit_breaker/shared/models/models.dart';

void main() {
  const calculator = RankingCalculator();
  const strength = ActivityCategory(id: 'strength', name: 'Força');
  const run = ActivityCategory(id: 'run', name: 'Corrida');
  const cycle = ActivityCategory(id: 'cycle', name: 'Ciclismo');
  const swim = ActivityCategory(id: 'swim', name: 'Natação');
  CategoryScore score(ActivityCategory category, double value) =>
      CategoryScore(category: category, normalizedScore: value);

  group('RankingCalculator', () {
    test('seleciona as três maiores, ordena e aplica 75/15/10', () {
      final result = calculator.calculate([
        score(run, 70),
        score(swim, 40),
        score(strength, 90),
        score(cycle, 80),
      ], now: DateTime(2026));
      expect(result.rankedCategories.map((item) => item.category.id), [
        'strength',
        'cycle',
        'run',
      ]);
      expect(result.totalScore, closeTo(86.5, .0001));
      expect(result.appliedWeights, [.75, .15, .10]);
      expect(result.isProvisional, isFalse);
    });

    test('categorias além das três maiores não alteram o total', () {
      final topThree = calculator.calculate([
        score(strength, 90),
        score(cycle, 80),
        score(run, 70),
      ]);
      final withExtra = calculator.calculate([
        score(strength, 90),
        score(cycle, 80),
        score(run, 70),
        score(swim, 1000),
      ]);
      expect(withExtra.rankedCategories.first.category, swim);
      expect(topThree.totalScore, 86.5);
      expect(withExtra.totalScore, 96.5);
      final lowExtra = calculator.calculate([
        score(strength, 90),
        score(cycle, 80),
        score(run, 70),
        score(swim, 1),
      ]);
      expect(lowExtra.totalScore, topThree.totalScore);
    });

    test('preserva resultado decimal', () {
      final result = calculator.calculate([
        score(strength, 91.5),
        score(cycle, 82.2),
        score(run, 73.7),
      ]);
      expect(result.totalScore, closeTo(88.325, .0001));
    });

    test('uma categoria retorna provisório sem total oficial', () {
      final result = calculator.calculate([score(strength, 90)]);
      expect(
        result.status,
        RankingCalculationStatus.provisionalInsufficientCategories,
      );
      expect(result.totalScore, isNull);
      expect(result.isProvisional, isTrue);
    });

    test('duas categorias retornam provisório sem redistribuir pesos', () {
      final result = calculator.calculate([
        score(strength, 90),
        score(run, 70),
      ]);
      expect(result.totalScore, isNull);
      expect(result.appliedWeights, [.75, .15]);
    });

    test('ausência de categorias retorna indisponível', () {
      final result = calculator.calculate(const []);
      expect(result.status, RankingCalculationStatus.unavailable);
      expect(result.rankedCategories, isEmpty);
    });

    test('limita valores normalizados à faixa de 0 a 100', () {
      final result = calculator.calculate([
        score(strength, 120),
        score(cycle, -10),
        score(run, 50),
      ]);
      expect(result.rankedCategories.map((item) => item.normalizedScore), [
        100,
        50,
        0,
      ]);
      expect(result.totalScore, 82.5);
    });
  });
}
