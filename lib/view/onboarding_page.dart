import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/build_context_extension.dart';
import '../core/shared_preferences_service.dart';

/// オンボーディング完了フラグ用[StateProvider]
///
///  外部から更新をすることで[SharedPreferencesService]側の値も更新する。
final isOnBoardingCompletedProvider = StateProvider<bool>((ref) {
  final sharedPreferencesService = ref.watch(sharedPreferencesServiceProvider);

  ref.listenSelf((_, next) {
    sharedPreferencesService.setBool(
      key: SharedPreferencesKey.isOnboardingCompleted,
      value: next,
    );
  });

  return sharedPreferencesService.getBool(
    key: SharedPreferencesKey.isOnboardingCompleted,
  );
});

/// オンボーディング用画面
class OnboardingPage extends ConsumerStatefulWidget {
  const OnboardingPage({super.key});

  @override
  ConsumerState<OnboardingPage> createState() => _OnboardingPageState();
}

class _OnboardingPageState extends ConsumerState<OnboardingPage> {
  late PageController _onboardingController;
  int currentOnboarding = 0;

  @override
  void initState() {
    super.initState();
    // 初期化
    _onboardingController = PageController()
      ..addListener(() {
        final page = _onboardingController.page!.round();
        setState(() {
          currentOnboarding = page;
        });
      });
  }

  @override
  Widget build(BuildContext context) {
    final isLastOnboarding = currentOnboarding == 2;

    return GestureDetector(
      onTap: isLastOnboarding
          ? () {
              ref
                  .read(isOnBoardingCompletedProvider.notifier)
                  .update((state) => true);
            }
          : () {
              _onboardingController.nextPage(
                duration: const Duration(milliseconds: 300),
                curve: Curves.linear,
              );
            },
      child: SizedBox(
        width: context.screenWidth,
        height: context.screenHeight,
        child: Column(
          children: [
            Flexible(
              child: PageView(
                controller: _onboardingController,
                children: const <Widget>[
                  _OnboardingContent(
                    imagePath: 'assets/images/new_onboarding1.png',
                  ),
                  _OnboardingContent(
                    imagePath: 'assets/images/new_onboarding2.png',
                  ),
                  _OnboardingContent(
                    imagePath: 'assets/images/new_onboarding3.png',
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _OnboardingContent extends StatelessWidget {
  const _OnboardingContent({
    required this.imagePath,
  });

  final String imagePath;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: MediaQuery.of(context).size.width,
      height: MediaQuery.of(context).size.height,
      child: Image.asset(imagePath, fit: BoxFit.cover),
    );
  }
}
