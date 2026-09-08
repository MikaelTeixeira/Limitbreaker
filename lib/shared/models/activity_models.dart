/// Categoria esportiva usada em atividades e no ranking.
class ActivityCategory {
  const ActivityCategory({required this.id, required this.name});

  final String id;
  final String name;
}

/// Grupo muscular usado em treinos de força.
class MuscleGroup {
  const MuscleGroup({required this.id, required this.name});

  final String id;
  final String name;
}

/// Pontuação de um grupo muscular para gráficos de radar.
class MuscleScore {
  const MuscleScore({required this.group, required this.value});

  final MuscleGroup group;
  final double value;
}

/// Pontuação normalizada de uma categoria esportiva.
class CategoryScore {
  const CategoryScore({required this.category, required this.normalizedScore});

  final ActivityCategory category;
  final double normalizedScore;
}

/// Atributo exibido em gráficos comparativos do dashboard.
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

/// Registro de atividade esportiva manual, como corrida ou ciclismo.
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

/// Recorde pessoal calculado a partir das atividades registradas.
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
