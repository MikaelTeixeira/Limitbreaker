import '../../../shared/models/models.dart';

class TrainingProfileCalculator {
  const TrainingProfileCalculator();

  TrainingProfile calculate({
    required List<HealthDisclosure> personalDisclosures,
    required List<HealthDisclosure> familyHistory,
    required ActivityBaseline activityBaseline,
    required bool requiresGentleTraining,
  }) {
    if (requiresGentleTraining) {
      return TrainingProfile.requiresGentleTraining;
    }

    final hasReportedConcern = [
      ...personalDisclosures,
      ...familyHistory,
    ].any((disclosure) => disclosure.isReported);
    if (hasReportedConcern) return TrainingProfile.hasLightConcerns;

    return switch (activityBaseline) {
      ActivityBaseline.active => TrainingProfile.completelyHealthy,
      ActivityBaseline.sedentary => TrainingProfile.healthy,
    };
  }
}
