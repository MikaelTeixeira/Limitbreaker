abstract final class PaceCalculator {
  static String? format({
    required String categoryId,
    required Duration? duration,
    required double? distanceKm,
  }) {
    if (duration == null || distanceKm == null || distanceKm <= 0) return null;
    final seconds = duration.inSeconds;
    final secondsPerUnit = switch (categoryId) {
      'swimming' => seconds / (distanceKm * 10),
      _ => seconds / distanceKm,
    };
    final rounded = secondsPerUnit.round();
    final minutes = rounded ~/ 60;
    final remainder = (rounded % 60).toString().padLeft(2, '0');
    final suffix = categoryId == 'swimming' ? '/100 m' : '/km';
    return '$minutes:$remainder $suffix';
  }
}
