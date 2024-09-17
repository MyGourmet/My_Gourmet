import 'dart:io';

import 'package:firebase_remote_config/firebase_remote_config.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:package_info/package_info.dart';
import 'package:url_launcher/url_launcher.dart';

import '../core/shared_preferences_service.dart';
import '../core/widgets/confirm_dialog.dart';
import '../core/widgets/navigation_frame.dart';
import 'auth/auth_repository.dart';
import 'auth/sign_in_page.dart';
import 'onboarding_page.dart';

/// 全てのページの基盤となるページ
///
/// 初期化処理が終わり次第、[NavigationFrame]を描画する。
class RootPage extends HookConsumerWidget {
  const RootPage({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isLoading = useState(true);

    // 初期化処理を行う非同期関数
    Future<void> init(WidgetRef ref, BuildContext context) async {
      await Future.wait([
        _checkBuildNumber(context),
        ref.watch(sharedPreferencesServiceProvider).init(),
      ]);

      final isSignedIn = ref.read(authRepositoryProvider).isSignedIn();
      if (!isSignedIn && context.mounted) {
        GoRouter.of(context).go(SignInPage.routePath);
      }
    }

    // フックの`useEffect`で初期化処理を行う
    useEffect(() {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        init(ref, context).then((_) {
          isLoading.value = false;
        });
      });
      return null;
    }, []);

    return isLoading.value
        ? const SizedBox.shrink() // ローディング中は空のウィジェットを表示
        : NavigationFrame(
            child: Stack(
              children: [
                child,
                if (!ref.watch(
                    isOnBoardingCompletedProvider)) // オンボーディングページが完了していない場合
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
        fetchTimeout: const Duration(seconds: 10),
        minimumFetchInterval: const Duration(minutes: 1),
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
