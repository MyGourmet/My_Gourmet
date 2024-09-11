import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

// TODO(kim): アナリティクスマージ後にコメントアウトを解除
// import '../../core/analytics/analytics_service.dart';
import '../../core/themes.dart';
import '../photo/swipe_photo/swipe_photo_page.dart';
import 'auth_controller.dart';

/// サインインページ
class SignInPage extends ConsumerWidget {
  const SignInPage({super.key});

  static const routeName = 'sign_in_page';
  static const routePath = '/sign_in_page';

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      body: ColoredBox(
        color: Themes.mainOrange, // 背景色をオレンジ色に設定
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Spacer(),
            // アプリアイコン部分
            Image.asset(
              'assets/images/sign_in/sign_in_icon.png', // 2枚目の画像パスに合わせてください
              width: 150,
              height: 150,
            ),
            const SizedBox(height: 20),
            const Spacer(),
            // Googleで続けるボタン
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: ElevatedButton.icon(
                onPressed: () async {
                  await ref.read(authControllerProvider).signInWithGoogle();
                  // TODO(kim): アナリティクスマージ後にコメントアウトを解除
                  // await ref.read(analyticsServiceProvider).sendEvent(
                  //       name: 'sign_in_with_google',
                  //     );
                  if (!context.mounted) {
                    return;
                  }
                  GoRouter.of(context).go(SwipePhotoPage.routePath);
                },
                icon: Image.asset(
                  'assets/images/sign_in/google_icon.png',
                  width: 24,
                ), // Googleアイコン
                label: const Text('Googleで続ける'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: Colors.black,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                  minimumSize:
                      const Size(double.infinity, 50), // 横幅を最大にして、高さを50に
                ),
              ),
            ),
            const SizedBox(height: 20),
            // Appleで続けるボタン
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: ElevatedButton.icon(
                onPressed: () async {
                  await ref.read(authControllerProvider).signInWithApple();
                  // TODO(kim): アナリティクスマージ後にコメントアウトを解除
                  // await ref.read(analyticsServiceProvider).sendEvent(
                  //       name: 'sign_in_with_apple',
                  //     );
                  if (!context.mounted) {
                    return;
                  }
                  GoRouter.of(context).go(SwipePhotoPage.routePath);
                },
                icon: Image.asset(
                  'assets/images/sign_in/apple_icon.png',
                  width: 24,
                ), // Appleアイコン
                label: const Text('Appleで続ける'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.black,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                  minimumSize:
                      const Size(double.infinity, 50), // 横幅を最大にして、高さを50に
                ),
              ),
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }
}
