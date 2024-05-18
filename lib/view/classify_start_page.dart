import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';

import '../core/build_context_extension.dart';
import '../core/shared_preferences_service.dart';
import 'swipe_photo_page.dart';

/// 写真分類スタート画面表示フラグ[StateProvider]
///
///  外部から更新をすることで[SharedPreferencesService]側の値も更新する。
final isClassifyOnboardingCompletedProvider = StateProvider<bool>((ref) {
  final sharedPreferencesService = ref.watch(sharedPreferencesServiceProvider);

  ref.listenSelf((_, next) {
    sharedPreferencesService.setBool(
      key: SharedPreferencesKey.isClassifyOnboardingCompleted,
      value: next,
    );
  });

  return sharedPreferencesService.getBool(
    key: SharedPreferencesKey.isClassifyOnboardingCompleted,
  );
});

/// 写真分類開始画面
class ClassifyStartPage extends ConsumerWidget {
  const ClassifyStartPage({super.key});

  static const routeName = 'classify_start_page';
  static const routePath = '/classify_start_page';

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return SafeArea(
      child: Scaffold(
        body: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Image.asset(
                    'assets/images/classify_photo.png',
                  ),
                  const Gap(32),
                  Text(
                    'スマホに入っている写真を読み込みます！',
                    style: context.textTheme.titleMedium,
                  ),
                  Text(
                    'ご飯の画像とそれ以外を分類してください。',
                    style: context.textTheme.titleMedium,
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(
                left: 16,
                right: 16,
                bottom: 16,
              ),
              child: ElevatedButton(
                onPressed: () {
                  ref
                      .read(isClassifyOnboardingCompletedProvider.notifier)
                      .update((state) => true);
                  context.go(SwipePhotoPage.routePath);
                },
                child: const Text('分類スタート'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
