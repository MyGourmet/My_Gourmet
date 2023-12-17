import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:my_gourmet/common/data/shared_preferences_repository.dart';

final onboardingControllerProvider =
    Provider<OnboardingController>(OnboardingController._);

class OnboardingController {
  OnboardingController._(this._ref);

  final Ref _ref;

  SharedPreferenceRepository get _sharedPreferencesRepository =>
      _ref.read(sharedPreferencesRepositoryProvider);

  bool hasShownOnboarding() {
    return _sharedPreferencesRepository.hasShownOnboarding();
  }

  Future<void> completedOnboarding() async {
    // ローカルデータにオンボーディング完了フラグを保存
    _sharedPreferencesRepository.setHasShownOnboarding(true);
  }
}
