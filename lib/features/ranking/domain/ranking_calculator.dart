import '../../../shared/models/models.dart';

abstract interface class CategoryScoreNormalizer {
  double normalize(CategoryScore score);
}

class PassThroughScoreNormalizer implements CategoryScoreNormalizer {
  const PassThroughScoreNormalizer();
  @override
  double normalize(CategoryScore score) =>
      score.normalizedScore.clamp(0, 100).toDouble();
}

enum RankingCalculationStatus {
  calculated,
  provisionalInsufficientCategories,
  unavailable,
}

enum RankingMetal { bronze, silver, gold, diamond, platinum }

class RankingStage {
  const RankingStage({
    required this.metal,
    required this.stage,
    required this.minimumScore,
  });

  final RankingMetal metal;
  final int stage;
  final double minimumScore;

  String get metalLabel => switch (metal) {
    RankingMetal.bronze => 'Bronze',
    RankingMetal.silver => 'Prata',
    RankingMetal.gold => 'Ouro',
    RankingMetal.diamond => 'Diamante',
    RankingMetal.platinum => 'Platina',
  };

  String get label => '$metalLabel $stage';
}

abstract final class RankingStageCatalog {
  static const _bandSize = 100 / 15;

  static RankingStage forScore(double score) {
    final index = (score.clamp(0, 100) / _bandSize).floor().clamp(0, 14);
    return RankingStage(
      metal: RankingMetal.values[index ~/ 3],
      stage: (index % 3) + 1,
      minimumScore: index * _bandSize,
    );
  }

  static List<RankingStage> get all => List.generate(
    15,
    (index) => RankingStage(
      metal: RankingMetal.values[index ~/ 3],
      stage: (index % 3) + 1,
      minimumScore: index * _bandSize,
    ),
  );
}

class RankingCalculationResult {
  const RankingCalculationResult({
    required this.totalScore,
    required this.rankedCategories,
    required this.appliedWeights,
    required this.isProvisional,
    required this.status,
    required this.calculatedAt,
  });
  final double? totalScore;
  final List<CategoryScore> rankedCategories;
  final List<double> appliedWeights;
  final bool isProvisional;
  final RankingCalculationStatus status;
  final DateTime calculatedAt;
}

class RankingCalculator {
  const RankingCalculator({
    this.normalizer = const PassThroughScoreNormalizer(),
  });
  static const weights = <double>[.75, .15, .10];
  final CategoryScoreNormalizer normalizer;

  RankingCalculationResult calculate(
    List<CategoryScore> scores, {
    DateTime? now,
  }) {
    final calculatedAt = now ?? DateTime.now();
    if (scores.isEmpty) {
      return RankingCalculationResult(
        totalScore: null,
        rankedCategories: const [],
        appliedWeights: const [],
        isProvisional: true,
        status: RankingCalculationStatus.unavailable,
        calculatedAt: calculatedAt,
      );
    }
    final sorted =
        scores
            .map(
              (item) => CategoryScore(
                category: item.category,
                normalizedScore: normalizer.normalize(item),
              ),
            )
            .toList()
          ..sort((a, b) => b.normalizedScore.compareTo(a.normalizedScore));
    final top = sorted.take(3).toList(growable: false);
    if (top.length < 3) {
      return RankingCalculationResult(
        totalScore: null,
        rankedCategories: top,
        appliedWeights: weights.take(top.length).toList(growable: false),
        isProvisional: true,
        status: RankingCalculationStatus.provisionalInsufficientCategories,
        calculatedAt: calculatedAt,
      );
    }
    final total = List.generate(
      3,
      (index) => top[index].normalizedScore * weights[index],
    ).reduce((a, b) => a + b);
    return RankingCalculationResult(
      totalScore: total,
      rankedCategories: top,
      appliedWeights: weights,
      isProvisional: false,
      status: RankingCalculationStatus.calculated,
      calculatedAt: calculatedAt,
    );
  }
}
