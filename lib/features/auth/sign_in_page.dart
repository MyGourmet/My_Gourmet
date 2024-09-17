import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

// TODO(kim): アナリティクスマージ後にコメントアウトを解除
// import '../../core/analytics/analytics_service.dart';
import '../../core/themes.dart';
import '../photo/swipe_photo/swipe_photo_page.dart';
import 'auth_controller.dart';

/// サインインページ
class SignInPage extends HookConsumerWidget {
  const SignInPage({super.key});

  static const routeName = 'sign_in_page';
  static const routePath = '/sign_in_page';

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // State Hookを使用して、UIがリビルドされても状態を保持する
    final isLoading = useState(false);

    // Googleでサインイン
    Future<void> handleGoogleSignIn() async {
      isLoading.value = true;
      await ref.read(authControllerProvider).signInWithGoogle();
      if (!context.mounted) {
        return;
      }
      GoRouter.of(context).go(SwipePhotoPage.routePath);
      isLoading.value = false;
    }

    // Appleでサインイン
    Future<void> handleAppleSignIn() async {
      isLoading.value = true;
      await ref.read(authControllerProvider).signInWithApple();
      if (!context.mounted) {
        return;
      }
      GoRouter.of(context).go(SwipePhotoPage.routePath);
      isLoading.value = false;
    }

    return Scaffold(
      body: ColoredBox(
        color: Themes.mainOrange,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Gap(120),
            const Spacer(),
            Image.asset(
              'assets/images/sign_in/sign_in_icon.png',
              width: 200,
              height: 200,
            ),
            const Gap(60),
            const Spacer(),
            // Googleで続けるボタン
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: ElevatedButton.icon(
                onPressed: isLoading.value ? null : handleGoogleSignIn,
                icon: Image.asset(
                  'assets/images/sign_in/google_icon.png',
                  width: 24,
                ),
                label: const Text('Googleで続ける'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: Colors.black,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                  minimumSize: const Size(double.infinity, 50),
                ),
              ),
            ),
            const Gap(20),
            // Appleで続けるボタン
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: ElevatedButton.icon(
                onPressed: isLoading.value ? null : handleAppleSignIn,
                icon: Image.asset(
                  'assets/images/sign_in/apple_icon.png',
                  width: 24,
                ),
                label: const Text('Appleで続ける'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.black,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                  minimumSize: const Size(double.infinity, 50),
                ),
              ),
            ),
            const Spacer(),
          ],
        ),
      ),
    );
  }
}
