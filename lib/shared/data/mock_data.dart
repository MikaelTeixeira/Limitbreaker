import '../models/models.dart';

abstract final class MockData {
  static final profile = UserProfile(
    id: 'user-victor',
    displayName: 'Victor Oliveira',
    age: 28,
    heightCm: 178,
    weightKg: 79,
    createdAt: DateTime(2026, 8, 6),
  );

  static const categories = <CategoryScore>[
    CategoryScore(
      category: ActivityCategory(id: 'strength', name: 'Musculação'),
      normalizedScore: 86,
    ),
    CategoryScore(
      category: ActivityCategory(id: 'running', name: 'Corrida'),
      normalizedScore: 68,
    ),
    CategoryScore(
      category: ActivityCategory(id: 'mobility', name: 'Mobilidade'),
      normalizedScore: 61,
    ),
    CategoryScore(
      category: ActivityCategory(id: 'cycling', name: 'Ciclismo'),
      normalizedScore: 55,
    ),
  ];

  static const workoutPlans = <WorkoutPlan>[
    WorkoutPlan(
      id: 'push-a',
      name: 'Peito + tríceps',
      groups: ['Peito', 'Tríceps'],
      exerciseCount: 3,
      estimatedMinutes: 52,
      exercises: [
        PlannedExercise(
          exercise: Exercise(
            id: 'bench-press',
            name: 'Supino reto',
            muscleGroup: 'Peito',
          ),
          targetSets: 3,
        ),
        PlannedExercise(
          exercise: Exercise(
            id: 'incline-press',
            name: 'Supino inclinado',
            muscleGroup: 'Peito',
          ),
          targetSets: 3,
        ),
        PlannedExercise(
          exercise: Exercise(
            id: 'triceps-pushdown',
            name: 'Tríceps pulley',
            muscleGroup: 'Tríceps',
          ),
          targetSets: 3,
        ),
      ],
    ),
    WorkoutPlan(
      id: 'legs-a',
      name: 'Pernas + core',
      groups: ['Pernas', 'Core'],
      exerciseCount: 3,
      estimatedMinutes: 58,
      exercises: [
        PlannedExercise(
          exercise: Exercise(
            id: 'squat',
            name: 'Agachamento livre',
            muscleGroup: 'Pernas',
          ),
          targetSets: 3,
        ),
        PlannedExercise(
          exercise: Exercise(
            id: 'leg-press',
            name: 'Leg press',
            muscleGroup: 'Pernas',
          ),
          targetSets: 3,
        ),
        PlannedExercise(
          exercise: Exercise(id: 'plank', name: 'Prancha', muscleGroup: 'Core'),
          targetSets: 3,
        ),
      ],
    ),
  ];

  static const categoryRadar = <RadarAttribute>[
    RadarAttribute(id: 'strength', label: 'Força', value: 86),
    RadarAttribute(id: 'run', label: 'Corrida', value: 68),
    RadarAttribute(id: 'mobility', label: 'Mobilidade', value: 61),
    RadarAttribute(id: 'cycling', label: 'Ciclismo', value: 55),
  ];

  static const muscles = <RadarAttribute>[
    RadarAttribute(id: 'chest', label: 'Peito', value: 78, previousValue: 70),
    RadarAttribute(id: 'back', label: 'Costas', value: 84, previousValue: 78),
    RadarAttribute(id: 'legs', label: 'Pernas', value: 72, previousValue: 69),
    RadarAttribute(id: 'arms', label: 'Braços', value: 75, previousValue: 71),
    RadarAttribute(id: 'core', label: 'Core', value: 64, previousValue: 60),
    RadarAttribute(
      id: 'shoulders',
      label: 'Ombros',
      value: 70,
      previousValue: 66,
    ),
  ];

  static const friends = <FriendSummary>[
    FriendSummary(
      displayName: 'Lívia Cardoso',
      rankingLabel: '#42',
      recentActivity: 'Treinou pernas hoje',
    ),
    FriendSummary(
      displayName: 'Rafael Silva',
      rankingLabel: '#67',
      recentActivity: 'Correu 8 km ontem',
    ),
    FriendSummary(
      displayName: 'Caio Mendes',
      rankingLabel: '#113',
      recentActivity: '3 dias em sequência',
    ),
    FriendSummary(
      displayName: 'Guilherme A.',
      rankingLabel: '#156',
      recentActivity: 'Conquista desbloqueada',
    ),
  ];

  static const achievements = <Achievement>[
    Achievement(
      id: 'first-week',
      title: 'PRIMEIRA SEMANA',
      type: AchievementType.official,
      influencesRanking: true,
    ),
    Achievement(
      id: 'discipline',
      title: 'DISCIPLINA',
      type: AchievementType.official,
      influencesRanking: true,
    ),
    Achievement(
      id: 'top-100',
      title: 'TOP 100',
      type: AchievementType.official,
      influencesRanking: true,
    ),
    Achievement(
      id: 'continuity',
      title: 'CONTINUIDADE',
      type: AchievementType.official,
      influencesRanking: true,
    ),
  ];
}
