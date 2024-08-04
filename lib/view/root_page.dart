import 'dart:io';

import 'package:firebase_remote_config/firebase_remote_config.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:package_info/package_info.dart';
import 'package:url_launcher/url_launcher.dart';

import '../core/shared_preferences_service.dart';
import '../features/auth/auth_repository.dart';
import 'classify_start_page.dart';
import 'home_page.dart';
import 'my_page.dart';
import 'onboarding_page.dart';
import 'swipe_photo_page.dart';
import 'widgets/confirm_dialog.dart';

/// 全てのページの基盤となるページ
///
/// 初期化処理が終わり次第、[_NavigationFrame]を描画する。
class RootPage extends ConsumerStatefulWidget {
  const RootPage({super.key, required this.child});

  final Widget child;

  @override
  ConsumerState<RootPage> createState() => _RootPageState();
}

class _RootPageState extends ConsumerState<RootPage>
    with SingleTickerProviderStateMixin {
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _init().then(
        (value) => setState(() {
          isLoading = false;
        }),
      );
    });
  }

  Future<void> _init() async {
    if (context.mounted) {
      await Future.wait([
        _checkBuildNumber(context),
        ref.watch(sharedPreferencesServiceProvider).init(),
      ]);
      final isOnboardingComplete = ref.watch(isOnBoardingCompletedProvider);
      if (isOnboardingComplete) {
        await ref.read(authRepositoryProvider).signInWithGoogle();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return isLoading
        ? const SizedBox.shrink()
        : _NavigationFrame(
            child: Stack(
              children: [
                widget.child,
                if (!ref.watch(isOnBoardingCompletedProvider))
                  const OnboardingPage(),
              ],
            ),
          );
  }

  /// 現在のビルド番号が適切かどうか確認するメソッド
  ///
  /// [FirebaseRemoteConfig]上の最低バージョンを下回っている場合、
  /// ストアに遷移してアップデートを促すダイアログを表示する。
  Future<void> _checkBuildNumber(BuildContext context) async {
    final remoteConfig = FirebaseRemoteConfig.instance;
    await remoteConfig.setConfigSettings(
      RemoteConfigSettings(
        fetchTimeout: const Duration(seconds: 1),
        minimumFetchInterval: const Duration(seconds: 1),
      ),
    );
    await remoteConfig.fetchAndActivate();
    final requiredBuildNumber = remoteConfig.getInt('requiredBuildNumber');
    final packageInfo = await PackageInfo.fromPlatform();
    final currentBuildNumber = int.parse(packageInfo.buildNumber);
    if (requiredBuildNumber > currentBuildNumber && context.mounted) {
      await ConfirmDialog.show(
        context,
        titleString: '緊急アップデートのお願い',
        contentString: '新しいバージョンが公開されました。\nアプリをアップデートしてください。',
        // アプリをアップデートせずに画面に戻って来た場合、引き続きダイアログが表示されている状態にしておく
        shouldPopOnConfirmed: false,
        onConfirmed: () async {
          if (Platform.isAndroid) {
            // TODO(masaki): Google Playにてアプリ作成後に動作確認
            await launchUrl(
              Uri.parse(
                'https://play.google.com/store/apps/details?id=com.blue_waltz.my_gourmet',
              ),
            );
          } else if (Platform.isIOS) {
            // TODO(masaki): AppStoreに飛ばす
          }
        },
      );
    }
  }
}

/// [BottomNavigationBar]を用いてページ遷移を管理するクラス
class _NavigationFrame extends ConsumerWidget {
  const _NavigationFrame({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isClassifyOnboardingCompleted =
        ref.watch(isClassifyOnboardingCompletedProvider);

    final isOnboardingComplete = ref.watch(isOnBoardingCompletedProvider);

    return Scaffold(
      body: child,
      bottomNavigationBar: isOnboardingComplete
          ? BottomNavigationBar(
              currentIndex:
                  _calcSelectedIndex(context, isClassifyOnboardingCompleted),
              onTap: (int index) =>
                  _onItemTapped(index, context, isClassifyOnboardingCompleted),
              items: const [
                BottomNavigationBarItem(
                  icon: Padding(
                    padding: EdgeInsets.only(top: 10),
                    child: Icon(
                      Icons.add,
                    ),
                  ),
                  label: '画像追加',
                ),
                BottomNavigationBarItem(
                  icon: Padding(
                    padding: EdgeInsets.only(top: 10),
                    child: Icon(
                      Icons.photo,
                    ),
                  ),
                  label: 'ギャラリー',
                ),
                BottomNavigationBarItem(
                  icon: Padding(
                    padding: EdgeInsets.only(top: 10),
                    child: Icon(
                      Icons.person,
                    ),
                  ),
                  label: 'マイページ',
                ),
              ],
            )
          : null,
    );
  }

  int _calcSelectedIndex(
    BuildContext context,
    bool isClassifyOnboardingCompleted,
  ) {
    final location = GoRouterState.of(context).uri.toString();

    const routeIndexMap = {
      SwipePhotoPage.routePath: 0,
      ClassifyStartPage.routePath: 0,
      HomePage.routePath: 1,
      MyPage.routePath: 2,
    };

    return routeIndexMap.entries
        .firstWhere(
          (entry) => location.contains(entry.key),
          orElse: () => throw UnimplementedError(),
        )
        .value;
  }

  void _onItemTapped(
    int index,
    BuildContext context,
    bool isClassifyOnboardingCompleted,
  ) {
    switch (index) {
      case 0:
        context.go(
          isClassifyOnboardingCompleted
              ? SwipePhotoPage.routePath
              : ClassifyStartPage.routePath,
        );
      case 1:
        context.go(HomePage.routePath);
      case 2:
        context.go(MyPage.routePath);
    }
  }
}

class CategoryFilterBar extends ConsumerWidget {
  const CategoryFilterBar({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // final selectedCategory = ref.watch(selectedCategoryProvider).state;
    const selectedCategory = '';

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
      child: const SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            CategoryButton(category: 'すべて', selectedCategory: selectedCategory),
            CategoryButton(
              category: 'ラーメン',
              selectedCategory: selectedCategory,
            ),
            CategoryButton(category: 'カフェ', selectedCategory: selectedCategory),
            CategoryButton(category: '和食', selectedCategory: selectedCategory),
            CategoryButton(category: '洋食', selectedCategory: selectedCategory),
            CategoryButton(
              category: 'エスニック',
              selectedCategory: selectedCategory,
            ),
          ],
        ),
      ),
    );
  }
}

class CategoryButton extends ConsumerWidget {
  const CategoryButton({
    super.key,
    required this.category,
    required this.selectedCategory,
  });
  final String category;
  final String selectedCategory;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isSelected = selectedCategory == category;

    return GestureDetector(
      onTap: () {},
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
        margin: const EdgeInsets.symmetric(horizontal: 4),
        decoration: BoxDecoration(
          color: isSelected ? Colors.orange : Colors.grey.shade200,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          category,
          style: TextStyle(
            color: isSelected ? Colors.white : Colors.black,
          ),
        ),
      ),
    );
  }
}
