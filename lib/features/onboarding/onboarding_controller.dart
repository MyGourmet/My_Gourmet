import 'package:flutter_riverpod/flutter_riverpod.dart';

final onboardingControllerProvider =
    Provider<OnboardingController>(OnboardingController._);

class OnboardingController {
  OnboardingController._(this._ref);

  final Ref _ref;
}
