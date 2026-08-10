enum UserGoal {
  gainMuscle,
  loseFat,
  conditioning,
  sportsPerformance,
  health,
  maintainFitness,
}

enum SportType { strength, running, cycling, swimming, football, martialArts }

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

class UserProfile {
  const UserProfile({
    required this.id,
    required this.email,
    required this.displayName,
    required this.age,
    required this.heightCm,
    required this.weightKg,
    required this.createdAt,
  });
  final String id;
  final String email;
  final String displayName;
  final int age;
  final double heightCm;
  final double weightKg;
  final DateTime createdAt;
}

class HealthAnswer {
  const HealthAnswer({required this.questionId, required this.optionId});
  final String questionId;
  final String optionId;
}

enum DisclosureStatus { noProblem, reported }

enum ActivityBaseline { active, sedentary }

enum TrainingProfile {
  completelyHealthy,
  healthy,
  hasLightConcerns,
  requiresGentleTraining,
}

class HealthDisclosure {
  const HealthDisclosure({
    required this.questionId,
    required this.status,
    this.description,
  });

  final String questionId;
  final DisclosureStatus status;
  final String? description;

  bool get isReported => status == DisclosureStatus.reported;
}

class HealthAssessment {
  const HealthAssessment({
    required this.personalDisclosures,
    required this.familyHistory,
    required this.activityBaseline,
    required this.requiresGentleTraining,
    required this.profile,
    required this.updatedAt,
  });

  final List<HealthDisclosure> personalDisclosures;
  final List<HealthDisclosure> familyHistory;
  final ActivityBaseline activityBaseline;
  final bool requiresGentleTraining;
  final TrainingProfile profile;
  final DateTime updatedAt;
}

class HealthProfile {
  const HealthProfile({
    required this.userId,
    required this.answers,
    required this.limitations,
    required this.updatedAt,
  });
  final String userId;
  final List<HealthAnswer> answers;
  final List<PhysicalLimitation> limitations;
  final DateTime updatedAt;
}

class FamilyHistoryAnswer extends HealthAnswer {
  const FamilyHistoryAnswer({
    required super.questionId,
    required super.optionId,
  });
}

class PhysicalLimitation {
  const PhysicalLimitation({
    required this.region,
    required this.type,
    required this.intensity,
    this.note,
  });
  final String region;
  final String type;
  final int intensity;
  final String? note;
}

class ConsentRecord {
  const ConsentRecord({
    required this.acceptedAt,
    required this.documentVersion,
  });
  final DateTime acceptedAt;
  final String documentVersion;
}

class ActivityCategory {
  const ActivityCategory({required this.id, required this.name});
  final String id;
  final String name;
}

class MuscleGroup {
  const MuscleGroup({required this.id, required this.name});
  final String id;
  final String name;
}

class MuscleScore {
  const MuscleScore({required this.group, required this.value});
  final MuscleGroup group;
  final double value;
}

class CategoryScore {
  const CategoryScore({required this.category, required this.normalizedScore});
  final ActivityCategory category;
  final double normalizedScore;
}

class RadarAttribute {
  const RadarAttribute({
    required this.id,
    required this.label,
    required this.value,
    this.previousValue,
    this.description,
  });
  final String id;
  final String label;
  final double value;
  final double? previousValue;
  final String? description;
}

class WorkoutPlan {
  const WorkoutPlan({
    required this.id,
    required this.name,
    required this.groups,
    required this.exerciseCount,
    this.estimatedMinutes,
    this.exercises = const [],
  });
  final String id;
  final String name;
  final List<String> groups;
  final int exerciseCount;
  final int? estimatedMinutes;
  final List<PlannedExercise> exercises;
}

class PlannedExercise {
  const PlannedExercise({required this.exercise, required this.targetSets});
  final Exercise exercise;
  final int targetSets;
}

class Exercise {
  const Exercise({
    required this.id,
    required this.name,
    required this.muscleGroup,
  });
  final String id;
  final String name;
  final String muscleGroup;
}

enum TrainingCategory { strength, running, cycling, swimming }

extension TrainingCategoryDetails on TrainingCategory {
  String get label => switch (this) {
    TrainingCategory.strength => 'Musculação',
    TrainingCategory.running => 'Corrida',
    TrainingCategory.cycling => 'Ciclismo',
    TrainingCategory.swimming => 'Natação',
  };
}

enum StrengthMuscleGroup {
  chest,
  shoulders,
  legs,
  biceps,
  triceps,
  abdomen,
  back,
}

extension StrengthMuscleGroupDetails on StrengthMuscleGroup {
  String get label => switch (this) {
    StrengthMuscleGroup.chest => 'Peito',
    StrengthMuscleGroup.shoulders => 'Ombro',
    StrengthMuscleGroup.legs => 'Pernas',
    StrengthMuscleGroup.biceps => 'Bíceps',
    StrengthMuscleGroup.triceps => 'Tríceps',
    StrengthMuscleGroup.abdomen => 'Abdômen',
    StrengthMuscleGroup.back => 'Costas',
  };
}

class StrengthExerciseLog {
  const StrengthExerciseLog({
    required this.id,
    required this.exerciseId,
    required this.loadKg,
    required this.repetitions,
    required this.performedAt,
  });

  final String id;
  final String exerciseId;
  final double loadKg;
  final int repetitions;
  final DateTime performedAt;
}

class ExerciseSet {
  const ExerciseSet({
    required this.repetitions,
    required this.loadKg,
    this.completed = true,
  });
  final int repetitions;
  final double loadKg;
  final bool completed;
}

class PerformedExercise {
  const PerformedExercise({required this.exercise, required this.sets});
  final Exercise exercise;
  final List<ExerciseSet> sets;
}

class WorkoutSession {
  const WorkoutSession({
    required this.id,
    required this.planId,
    required this.performedAt,
    required this.duration,
    this.exercises = const [],
    this.completedAt,
    this.note,
  });
  final String id;
  final String planId;
  final DateTime performedAt;
  final Duration duration;
  final List<PerformedExercise> exercises;
  final DateTime? completedAt;
  final String? note;
}

class ActivitySession {
  const ActivitySession({
    required this.id,
    required this.categoryId,
    required this.performedAt,
    this.distanceKm,
    this.duration,
    this.intensity,
  });
  final String id;
  final String categoryId;
  final DateTime performedAt;
  final double? distanceKm;
  final Duration? duration;
  final int? intensity;
}

class PersonalRecord {
  const PersonalRecord({
    required this.id,
    required this.label,
    required this.value,
    required this.achievedAt,
  });
  final String id;
  final String label;
  final double value;
  final DateTime achievedAt;
}

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

enum AchievementType { official, personal }

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

class AchievementProgress {
  const AchievementProgress({required this.current, required this.target});
  final double current;
  final double target;
}

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

class Friendship {
  const Friendship({required this.userId, required this.friendId});
  final String userId;
  final String friendId;
}

class FriendSummary {
  const FriendSummary({
    required this.displayName,
    required this.rankingLabel,
    required this.recentActivity,
  });
  final String displayName;
  final String rankingLabel;
  final String recentActivity;
}

enum FriendRequestStatus { pending, accepted, declined }

enum FriendRequestDirection { received, sent }

class FriendRequest {
  const FriendRequest({
    required this.id,
    required this.fromUserId,
    required this.displayName,
    required this.status,
    required this.direction,
  });
  final String id;
  final String fromUserId;
  final String displayName;
  final FriendRequestStatus status;
  final FriendRequestDirection direction;
}

class ChatConversation {
  const ChatConversation({required this.id, required this.title});
  final String id;
  final String title;
}

class ChatMember {
  const ChatMember({required this.userId, required this.conversationId});
  final String userId;
  final String conversationId;
}

class ChatMessage {
  const ChatMessage({
    required this.id,
    required this.conversationId,
    required this.authorId,
    required this.text,
    required this.sentAt,
  });
  final String id;
  final String conversationId;
  final String authorId;
  final String text;
  final DateTime sentAt;
}
