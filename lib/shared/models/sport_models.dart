/// Objetivo principal escolhido no onboarding.
enum UserGoal {
  gainMuscle,
  loseFat,
  conditioning,
  sportsPerformance,
  health,
  maintainFitness,
}

/// Modalidades usadas para montar as prioridades esportivas do usuário.
enum SportType { strength, running, cycling, swimming, football, martialArts }

/// Textos e assets associados a cada modalidade do onboarding.
extension SportTypeDetails on SportType {
  String get label => switch (this) {
    SportType.strength => 'Musculação',
    SportType.running => 'Corrida',
    SportType.cycling => 'Ciclismo',
    SportType.swimming => 'Natação',
    SportType.football => 'Futebol',
    SportType.martialArts => 'Lutas',
  };

  String get assetPath => switch (this) {
    SportType.strength => 'assets/images/sports/strength.png',
    SportType.running => 'assets/images/sports/running.png',
    SportType.cycling => 'assets/images/sports/cycling.png',
    SportType.swimming => 'assets/images/sports/swimming.png',
    SportType.football => 'assets/images/sports/football.png',
    SportType.martialArts => 'assets/images/sports/martial_arts.png',
  };
}
