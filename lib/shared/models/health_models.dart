/// Resposta simples para perguntas de saúde do onboarding.
class HealthAnswer {
  const HealthAnswer({required this.questionId, required this.optionId});

  final String questionId;
  final String optionId;
}

/// Indica se a pessoa declarou ou não uma condição de saúde.
enum DisclosureStatus { noProblem, reported }

/// Resume se a pessoa já possui rotina ativa ou sedentária.
enum ActivityBaseline { active, sedentary }

/// Perfil de treino calculado a partir das respostas de saúde.
enum TrainingProfile {
  completelyHealthy,
  healthy,
  hasLightConcerns,
  requiresGentleTraining,
}

/// Declaração de condição pessoal ou histórico familiar.
class HealthDisclosure {
  const HealthDisclosure({
    required this.questionId,
    required this.status,
    this.description,
  });

  final String questionId;
  final DisclosureStatus status;
  final String? description;

  /// Retorna verdadeiro quando a pessoa informou algum ponto de atenção.
  bool get isReported => status == DisclosureStatus.reported;
}

/// Resultado consolidado das respostas de saúde do onboarding.
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

/// Perfil de saúde legado mantido para telas e integrações provisórias.
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

/// Resposta específica para histórico familiar.
class FamilyHistoryAnswer extends HealthAnswer {
  const FamilyHistoryAnswer({
    required super.questionId,
    required super.optionId,
  });
}

/// Limitação física relatada pela pessoa no onboarding.
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

/// Registro do aceite de termos e consentimentos.
class ConsentRecord {
  const ConsentRecord({
    required this.acceptedAt,
    required this.documentVersion,
  });

  final DateTime acceptedAt;
  final String documentVersion;
}
