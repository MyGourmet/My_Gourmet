import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';


import '../core/build_context_extension.dart';
import '../core/shared_preferences_service.dart';
import '../core/widgets/custom_elevated_button.dart';
import 'photo/swipe_photo/classify_start_page.dart';

/// オンボーディング完了フラグ用[StateProvider]
///
/// 外部から更新をすることで[SharedPreferencesService]側の値も更新する。
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
class OnboardingPage extends HookConsumerWidget {
  const OnboardingPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final pageController = usePageController();
    final currentOnboarding = useState(0);

    useEffect(() {
      pageController.addListener(() {
        final page = pageController.page!.round();
        currentOnboarding.value = page;
      });
      return null;
    }, [pageController],);

    final isLastPage = currentOnboarding.value == 2;
    final indicatorPadding = context.screenHeight * 0.035;
    final bottomPadding = context.screenHeight * 0.05;

    return Scaffold(
      body: SafeArea(
        child: Stack(
          children: <Widget>[
            PageView(
              controller: pageController,
              onPageChanged: (int page) {
                  currentOnboarding.value = page;
              },
              children: <Widget>[
                Container(
                  margin: EdgeInsets.only(bottom: indicatorPadding),
                  decoration: const BoxDecoration(
                    image: DecorationImage(
                      image: AssetImage('assets/images/onboarding1.png'),
                      fit: BoxFit.contain,
                    ),
                  ),
                ),
                Container(
                  margin: EdgeInsets.only(bottom: indicatorPadding),
                  decoration: const BoxDecoration(
                    image: DecorationImage(
                      image: AssetImage('assets/images/onboarding2.png'),
                      fit: BoxFit.contain,
                    ),
                  ),
                ),
                Container(
                  margin: EdgeInsets.only(bottom: indicatorPadding),
                  decoration: const BoxDecoration(
                    image: DecorationImage(
                      image: AssetImage('assets/images/onboarding3.png'),
                      fit: BoxFit.contain,
                    ),
                  ),
                ),
              ],
            ),
            SafeArea(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                children: <Widget>[
                  SmoothPageIndicator(
                    controller: pageController,
                    count: 3,
                    effect: WormEffect(
                      dotHeight: 12,
                      dotWidth: 12,
                      spacing: 24,
                      activeDotColor: Colors.grey[800]!,
                      dotColor: Colors.grey[400]!,
                    ),
                    onDotClicked: (index) {
                      pageController.animateToPage(
                        index,
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.easeInOut,
                      );
                    },
                  ),
                  Gap(indicatorPadding),
                  Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: MediaQuery.of(context).size.width * 0.05,
                    ),
                    child: SizedBox(
                      height: 60,
                      child: CustomElevatedButton(
                        onPressed: () {
                          if (!isLastPage) {
                          pageController.nextPage(
                              duration: const Duration(milliseconds: 300),
                              curve: Curves.easeInOut,
                            );
                          } else {
                            ref
                                .read(isOnBoardingCompletedProvider.notifier)
                                .update((state) => true);
                            context.go(ClassifyStartPage.routePath);
                          }
                        },
                        text: isLastPage ? 'やってみる' : 'つぎへ',
                      ),
                    ),
                  ),
                  Gap(bottomPadding),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
