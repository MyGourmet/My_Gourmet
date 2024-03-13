import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';

import '../core/build_context_extension.dart';
import '../core/constants.dart';
import '../core/shared_preferences_service.dart';
import '../core/themes.dart';

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
    final screenWidth = context.deviceWidth;
    final screenHeight = context.deviceHeight;
    final isOnboardingTop = currentOnboarding == 0;
    final isNotLastOnboarding = currentOnboarding != 3;

    return GestureDetector(
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
        color: Themes.gray.shade900.withOpacity(0.9),
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
                        // ignore: lines_longer_than_80_chars
                        '素敵なごはんやお店の写真が\nフォルダ内であちこちにあったり。\nせっかく撮ってもそれっきりで\n見返すことがなかったり。',
                    imagePath: 'assets/images/onboarding1.png',
                    imageWidth: 160,
                  ),
                  const _OnboardingContent(
                    title: 'あなたの画像ライブラリから\n食べ物の写真のみを\n自動ピックアップします！',
                    description:
                        // ignore: lines_longer_than_80_chars
                        'MyGourmetではあなたの画像フォルダの\nすべての画像を自動で解析し\n食べ物の写真のみ表示させることができます。',
                    imagePath: 'assets/images/onboarding2.png',
                    imageWidth: 220,
                  ),
                  const _OnboardingContent(
                    title: 'あなただけの\n食の思い出アルバムが\n出来上がります！',
                    description:
                        // ignore: lines_longer_than_80_chars
                        'それぞれの料理の味わいや体験を\nひと目で見返せるようになります。\n\nさあ、さっそく今までの写真を\n記録してみましょう！',
                    imagePath: 'assets/images/onboarding3.png',
                    imageWidth: 140,
                  ),
                ],
              ),
            ),
            if (!isOnboardingTop)
              ElevatedButton(
                onPressed: () async {
                  if (isNotLastOnboarding) {
                    await _onboardingController.nextPage(
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.linear,
                    );
                  } else {
                    // オンボーディング完了フラグをたてる
                    ref
                        .read(isOnBoardingCompletedProvider.notifier)
                        .update((state) => true);
                  }
                },
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 48),
                ),
                child: Text(
                  isNotLastOnboarding ? 'つぎへ' : 'はじめる',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
            const Gap(28),
          ],
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
          const Gap(28),
          Text(
            title,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 18,
              decoration: TextDecoration.none,
              fontFamily: kZenkakuGothicNew, // なぜかフォントが適用されないので直接指定
            ),
            textAlign: TextAlign.center,
          ),
          const Gap(28),
          Image.asset(imagePath, width: imageWidth ?? screenWidth / 2.5),
          const Gap(28),
          Text(
            description,
            style: const TextStyle(
              color: Colors.white,
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
