import 'package:flutter_test/flutter_test.dart';
import 'package:limit_breaker/features/onboarding/domain/training_profile_calculator.dart';
import 'package:limit_breaker/shared/models/models.dart';

void main() {
  const calculator = TrainingProfileCalculator();

  test('perfil 1 exige atividade e nenhuma preocupação informada', () {
    final profile = calculator.calculate(
      personalDisclosures: const [],
      familyHistory: const [],
      activityBaseline: ActivityBaseline.active,
      requiresGentleTraining: false,
    );

    expect(profile, TrainingProfile.completelyHealthy);
  });

  test('perfil 2 representa pessoa sem preocupações, mas sedentária', () {
    final profile = calculator.calculate(
      personalDisclosures: const [],
      familyHistory: const [],
      activityBaseline: ActivityBaseline.sedentary,
      requiresGentleTraining: false,
    );

    expect(profile, TrainingProfile.healthy);
  });

  test('perfil 3 é usado para condição ou histórico familiar informado', () {
    final profile = calculator.calculate(
      personalDisclosures: const [
        HealthDisclosure(
          questionId: 'respiratory',
          status: DisclosureStatus.reported,
          description: 'Asma controlada',
        ),
      ],
      familyHistory: const [],
      activityBaseline: ActivityBaseline.active,
      requiresGentleTraining: false,
    );

    expect(profile, TrainingProfile.hasLightConcerns);
  });

  test('perfil 4 depende de indicação explícita de treino muito leve', () {
    final profile = calculator.calculate(
      personalDisclosures: const [],
      familyHistory: const [],
      activityBaseline: ActivityBaseline.active,
      requiresGentleTraining: true,
    );

    expect(profile, TrainingProfile.requiresGentleTraining);
  });
}
