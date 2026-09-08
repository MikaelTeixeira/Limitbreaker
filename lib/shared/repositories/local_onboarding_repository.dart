import 'package:shared_preferences/shared_preferences.dart';

import 'repository_contracts.dart';

/// Guarda localmente se a pessoa já concluiu o onboarding.
class LocalOnboardingRepository implements OnboardingRepository {
  static const _key = 'onboarding_complete';

  @override
  Future<bool> isComplete() async =>
      (await SharedPreferences.getInstance()).getBool(_key) ?? false;

  @override
  Future<void> complete() async =>
      (await SharedPreferences.getInstance()).setBool(_key, true);
}
