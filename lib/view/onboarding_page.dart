import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

import '../core/shared_preferences_service.dart';
import '../core/themes.dart';

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
class OnboardingPage extends ConsumerStatefulWidget {
  const OnboardingPage({super.key});

  @override
  ConsumerState<OnboardingPage> createState() => _OnboardingPageState();
}

class _OnboardingPageState extends ConsumerState<OnboardingPage> {
  final PageController _pageController = PageController();
  int currentOnboarding = 0;

  @override
  void initState() {
    super.initState();
    _pageController.addListener(() {
      final page = _pageController.page!.round();
      setState(() {
        currentOnboarding = page;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final isLastPage = currentOnboarding == 2; // 最後のページ判定

    return Scaffold(
      body: Stack(
        children: <Widget>[
          PageView(
            controller: _pageController, // PageControllerをPageViewに接続
            onPageChanged: (int page) {
              setState(() {
                currentOnboarding = page;
              });
            },
            children: <Widget>[
              Container(
                decoration: BoxDecoration(
                  image: DecorationImage(
                    image: AssetImage('assets/images/new_onboarding1.png'),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              Container(
                decoration: BoxDecoration(
                  image: DecorationImage(
                    image: AssetImage('assets/images/new_onboarding2.png'),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              Container(
                decoration: BoxDecoration(
                  image: DecorationImage(
                    image: AssetImage('assets/images/new_onboarding3.png'),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(
            height: 20,
          ),
          SafeArea(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.end,
              children: <Widget>[
                Center(
                  child: Padding(
                    padding: const EdgeInsets.only(top: 20.0),
                    child: SmoothPageIndicator(
                      controller: _pageController, // PageControllerを渡す
                      count: 3, // ページの数を3に設定
                      effect: WormEffect(
                        dotHeight: 12, // 点の高さを小さくする
                        dotWidth: 12, // 点の幅を小さくする
                        spacing: 23,
                        activeDotColor: Colors.grey[800]!, // アクティブな点の色を濃い灰色にする
                        dotColor: Colors.grey[400]!, // 非アクティブな点の色を薄い灰色にする
                      ), // インジケータのエフェクト
                      onDotClicked: (index) {
                        _pageController.animateToPage(
                          index,
                          duration: Duration(milliseconds: 300),
                          curve: Curves.easeInOut,
                        );
                      },
                    ),
                  ),
                ),
                SizedBox(height: 28),
                Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: MediaQuery.of(context).size.width * 0.05,
                  ),
                  child: Container(
                    height: 60, // お好みの高さに設定してください
                    decoration: BoxDecoration(
                      color: Themes.mainOrange, // 背景色
                      borderRadius: BorderRadius.circular(8.0), // 角の丸み
                    ),
                    child: InkWell(
                      onTap: () {
                        if (!isLastPage) {
                          _pageController.nextPage(
                            duration: Duration(milliseconds: 300),
                            curve: Curves.easeInOut,
                          );
                        } else {
                          ref
                              .read(isOnBoardingCompletedProvider.notifier)
                              .update((state) => true);
                        }
                      },
                      child: Row(
                        children: <Widget>[
                          Expanded(
                            child: Align(
                              alignment: Alignment.center,
                              child: Text(
                                isLastPage ? 'はじめる' : 'やってみる',
                                style: const TextStyle(
                                  fontSize: 20,
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 43),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
