import 'package:limit_breaker/shared/models/models.dart';

/// Calcula recordes explicáveis a partir das atividades persistidas.
class PersonalRecordCalculator {
  const PersonalRecordCalculator();

  List<PersonalRecord> calculate(List<ActivitySession> activities) {
    final records = <PersonalRecord>[];
    for (final category in const ['running', 'cycling', 'swimming']) {
      final valid = activities
          .where(
            (item) =>
                item.categoryId == category &&
                item.distanceKm != null &&
                item.distanceKm! > 0 &&
                item.duration != null &&
                item.duration!.inSeconds > 0,
          )
          .toList();
      if (valid.isEmpty) continue;

      final longest = _best(valid, (item) => item.distanceKm!, false);
      records.add(
        PersonalRecord(
          id: '$category-distance',
          label: _distanceLabel(category),
          value: category == 'swimming'
              ? longest.distanceKm! * 1000
              : longest.distanceKm!,
          unit: category == 'swimming' ? 'm' : 'km',
          achievedAt: longest.performedAt,
        ),
      );

      final performance = _best(
        valid,
        category == 'cycling' ? _speed : (item) => _pace(item, category),
        category != 'cycling',
      );
      records.add(
        PersonalRecord(
          id: '$category-performance',
          label: category == 'cycling'
              ? 'Maior velocidade no ciclismo'
              : category == 'swimming'
              ? 'Melhor pace na natação'
              : 'Melhor pace na corrida',
          value: category == 'cycling'
              ? _speed(performance)
              : _pace(performance, category),
          unit: category == 'cycling'
              ? 'km/h'
              : category == 'swimming'
              ? 's/100m'
              : 's/km',
          achievedAt: performance.performedAt,
        ),
      );
    }
    return records;
  }

  double _speed(ActivitySession item) =>
      item.distanceKm! / (item.duration!.inSeconds / 3600);

  double _pace(ActivitySession item, String category) =>
      item.duration!.inSeconds /
      (category == 'swimming' ? item.distanceKm! * 10 : item.distanceKm!);

  ActivitySession _best(
    List<ActivitySession> items,
    double Function(ActivitySession) score,
    bool preferLower,
  ) {
    final ordered = [...items]
      ..sort((a, b) {
        final comparison = score(a).compareTo(score(b));
        if (comparison != 0) return preferLower ? comparison : -comparison;
        final date = a.performedAt.compareTo(b.performedAt);
        return date != 0 ? date : a.id.compareTo(b.id);
      });
    return ordered.first;
  }

  String _distanceLabel(String category) => switch (category) {
    'cycling' => 'Maior pedal',
    'swimming' => 'Maior distância na natação',
    _ => 'Maior corrida',
  };
}
