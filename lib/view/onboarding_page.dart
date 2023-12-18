import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:my_gourmet/core/app_colors.dart';
import 'package:my_gourmet/core/build_context_extension.dart';
import 'package:my_gourmet/core/constants.dart';
import 'package:my_gourmet/core/shared_preferences_service.dart';
import 'package:my_gourmet/view/home_page.dart';

import 'widgets/buttons.dart';

/// オンボーディング用画面
///
/// [SharedPreferencesService]を参照して[HomePage]上に表示するかどうかを判断する。
class OnboardingPage extends ConsumerStatefulWidget {
  const OnboardingPage({super.key});

  @override
  ConsumerState<OnboardingPage> createState() => _OnboardingPageState();
}

class _OnboardingPageState extends ConsumerState<OnboardingPage> {
  bool hasShownOnboarding = false;
  late PageController _onboardingController;
  int currentOnboarding = 0;
  late SharedPreferencesService _sharedPreferencesService;

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
  didChangeDependencies() {
    super.didChangeDependencies();
    // Providerを参照する_sharedPreferencesServiceはここで初期化
    _sharedPreferencesService = ref.watch(sharedPreferencesServiceProvider);
    hasShownOnboarding = _sharedPreferencesService.getBool(
        key: SharedPreferencesKey.isOnboardingCompleted);
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = context.deviceWidth;
    final screenHeight = context.deviceHeight;
    bool isOnboardingTop = currentOnboarding == 0;
    bool isNotLastOnboarding = currentOnboarding != 3;

    return Visibility(
      visible: !hasShownOnboarding,
      child: GestureDetector(
        // オンボーディング初めのロゴ画面の場合、画面タップで遷移させる
        onTap: isOnboardingTop
            ? () {
                _onboardingController.nextPage(
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.linear,
                );
              }
            : null,
        child: Container(
          color: AppColors.black.withOpacity(0.9),
          width: screenWidth,
          height: screenHeight,
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            children: [
              Flexible(
                child: PageView(
                  controller: _onboardingController,
                  children: <Widget>[
                    Center(
                      child: Image.asset(
                        'assets/images/top_image.png',
                        width: screenWidth / 2,
                      ),
                    ),
                    const _OnboardingContent(
                      title: 'せっかく撮った食べ物の写真\nそのままになっていませんか？\n',
                      description:
                          '素敵なごはんやお店の写真が\nフォルダ内であちこちにあったり。\nせっかく撮ってもそれっきりで\n見返すことがなかったり。',
                      imagePath: 'assets/images/onboarding1.png',
                      imageWidth: 160,
                    ),
                    const _OnboardingContent(
                      title: 'あなたの画像ライブラリから\n食べ物の写真のみを\n自動ピックアップします！',
                      description:
                          'MyGourmetではあなたの画像フォルダの\nすべての画像を自動で解析し\n食べ物の写真のみ表示させることができます。',
                      imagePath: 'assets/images/onboarding2.png',
                      imageWidth: 220,
                    ),
                    const _OnboardingContent(
                      title: 'あなただけの\n食の思い出アルバムが\n出来上がります！',
                      description:
                          'それぞれの料理の味わいや体験を\nひと目で見返せるようになります。\n\nさあ、さっそく今までの写真を\n記録してみましょう！',
                      imagePath: 'assets/images/onboarding3.png',
                      imageWidth: 140,
                    ),
                  ],
                ),
              ),
              if (!isOnboardingTop)
                CustomButton.orange(
                  onPressed: () async {
                    if (isNotLastOnboarding) {
                      _onboardingController.nextPage(
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.linear,
                      );
                    } else {
                      // オンボーディング完了フラグをたてる
                      hasShownOnboarding =
                          await _sharedPreferencesService.setBool(
                              key: SharedPreferencesKey.isOnboardingCompleted,
                              value: true);
                      setState(() {});
                    }
                  },
                  text: isNotLastOnboarding ? 'つぎへ' : 'はじめる',
                ),
              const Gap(32),
            ],
          ),
        ),
      ),
    );
  }
}

class _OnboardingContent extends StatelessWidget {
  const _OnboardingContent({
    required this.title,
    required this.description,
    required this.imagePath,
    this.imageWidth,
  });

  final String title;
  final String description;
  final String imagePath;
  final double? imageWidth;

  @override
  Widget build(BuildContext context) {
    final screenWidth = context.deviceWidth;
    return Center(
      child: Column(
        children: [
          const Gap(64),
          Image.asset(
            'assets/images/food_memory.png',
            width: screenWidth / 2,
          ),
          const Gap(32),
          Text(
            title,
            style: const TextStyle(
              color: AppColors.white,
              fontWeight: FontWeight.bold,
              fontSize: 18,
              decoration: TextDecoration.none,
              fontFamily: kZenkakuGothicNew, // なぜかフォントが適用されないので直接指定
            ),
            textAlign: TextAlign.center,
          ),
          const Gap(32),
          Image.asset(imagePath, width: imageWidth ?? screenWidth / 2.5),
          const Gap(32),
          Text(
            description,
            style: const TextStyle(
              color: AppColors.white,
              fontSize: 14,
              decoration: TextDecoration.none,
              fontFamily: kZenkakuGothicNew, // なぜかフォントが適用されないので直接指定
            ),
          ),
        ],
      ),
    );
  }
}
