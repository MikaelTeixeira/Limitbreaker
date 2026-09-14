import 'package:shared_preferences/shared_preferences.dart';

/// Guarda localmente se a pessoa já concluiu o onboarding.
class LocalOnboardingRepository {
  static const _key = 'onboarding_complete';

  Future<bool> isComplete() async =>
      (await SharedPreferences.getInstance()).getBool(_key) ?? false;

  Future<void> complete() async =>
      (await SharedPreferences.getInstance()).setBool(_key, true);
}
