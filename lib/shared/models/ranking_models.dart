/// Estágio visual do ranking da pessoa.
class RankingLevel {
  const RankingLevel({
    required this.id,
    required this.name,
    required this.minimumScore,
    this.isProvisional = true,
  });

  final String id;
  final String name;
  final double minimumScore;
  final bool isProvisional;
}

/// Foto histórica da pontuação e posição global.
class RankingSnapshot {
  const RankingSnapshot({
    required this.score,
    required this.globalPosition,
    required this.recordedAt,
  });

  final double score;
  final int globalPosition;
  final DateTime recordedAt;
}
