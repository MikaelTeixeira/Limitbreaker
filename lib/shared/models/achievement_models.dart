/// Tipo de conquista exibida no aplicativo.
enum AchievementType { official, personal }

/// Conquista oficial ou pessoal.
class Achievement {
  const Achievement({
    required this.id,
    required this.title,
    required this.type,
    required this.influencesRanking,
  });

  final String id;
  final String title;
  final AchievementType type;
  final bool influencesRanking;
}

/// Progresso atual de uma conquista.
class AchievementProgress {
  const AchievementProgress({required this.current, required this.target});

  final double current;
  final double target;
}

/// Conquista vinculada a uma pessoa e seu progresso.
class UserAchievement {
  const UserAchievement({
    required this.achievement,
    required this.progress,
    this.unlockedAt,
  });

  final Achievement achievement;
  final AchievementProgress progress;
  final DateTime? unlockedAt;
}
