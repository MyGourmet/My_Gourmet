import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:my_gourmet/common/presentation/app_colors.dart';
import 'package:my_gourmet/common/presentation/widgets/buttons.dart';

class OnboardingPage extends ConsumerStatefulWidget {
  const OnboardingPage({super.key});

  @override
  ConsumerState<OnboardingPage> createState() => _OnboardingPageState();
}

class _OnboardingPageState extends ConsumerState<OnboardingPage> {
  bool hasShownOnboarding = false;
  late PageController _onboardingcController;
  int currentOnboarding = 0;

  @override
  void initState() {
    super.initState();
    // TODO:ここでオンボーディング済みかどうか確認する
    // 初期化
    _onboardingcController = PageController()
      ..addListener(() {
        final page = _onboardingcController.page!.round();
        setState(() {
          currentOnboarding = page;
        });
      });
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    bool isOnboardingTop = currentOnboarding == 0;
    bool isNotLastOnboarding = currentOnboarding != 3;

    return Visibility(
      visible: !hasShownOnboarding,
      child: GestureDetector(
        // オンボーディング初めのロゴ画面の場合、画面タップで遷移させる
        onTap: isOnboardingTop
            ? () {
                _onboardingcController.nextPage(
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
                  controller: _onboardingcController,
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
                  onPressed: () {
                    if (isNotLastOnboarding) {
                      _onboardingcController.nextPage(
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.linear,
                      );
                    } else {
                      // ここでオンボーディング完了フラグたてる
                      setState(() {
                        hasShownOnboarding = true;
                      });
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
    final screenWidth = MediaQuery.of(context).size.width;
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
              fontFamily: 'ZenkakuGothicNew', // なぜかフォントが適用されないので直接指定
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
              fontFamily: 'ZenkakuGothicNew', // なぜかフォントが適用されないので直接指定
            ),
          ),
        ],
      ),
    );
  }
}
