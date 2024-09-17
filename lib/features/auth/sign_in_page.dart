import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
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
                onPressed: () async {
                  await ref.read(authControllerProvider).signInWithGoogle();
                  if (!context.mounted) {
                    return;
                  }
                  GoRouter.of(context).go(SwipePhotoPage.routePath);
                },
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
                onPressed: () async {
                  await ref.read(authControllerProvider).signInWithApple();
                  if (!context.mounted) {
                    return;
                  }
                  GoRouter.of(context).go(SwipePhotoPage.routePath);
                },
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
