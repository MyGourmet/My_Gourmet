import 'dart:io';

import 'package:firebase_remote_config/firebase_remote_config.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:package_info/package_info.dart';
import 'package:url_launcher/url_launcher.dart';

import '../core/logger.dart';
import '../core/shared_preferences_service.dart';
import '../core/widgets/confirm_dialog.dart';
import '../core/widgets/navigation_frame.dart';
import 'auth/auth_repository.dart';
import 'onboarding_page.dart';

/// 全てのページの基盤となるページ
///
/// 初期化処理が終わり次第、[NavigationFrame]を描画する。
class RootPage extends ConsumerStatefulWidget {
  const RootPage({super.key, required this.child});

  final Widget child;

  @override
  ConsumerState<RootPage> createState() => _RootPageState();
}

class _RootPageState extends ConsumerState<RootPage> {
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
        _fetchRemoteConfigAndCheckBuildNumber(context),
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
        : NavigationFrame(
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
  Future<void> _fetchRemoteConfigAndCheckBuildNumber(
    BuildContext context,
  ) async {
    final remoteConfig = FirebaseRemoteConfig.instance;
    try {
      await remoteConfig.setConfigSettings(
        RemoteConfigSettings(
          fetchTimeout: const Duration(minutes: 10),
          minimumFetchInterval: kReleaseMode
              ? const Duration(hours: 1)
              : const Duration(minutes: 1),
        ),
      );
      await remoteConfig.setDefaults({
        'gallery_view': 'rectangle',
      });

      // リモート設定を取得して適用
      final activated = await remoteConfig.fetchAndActivate();
      debugPrint('API call successful: $activated');

      // リモート設定を基に処理を進める
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
              // TODO(kim): リリース後に動作確認
              await launchUrl(
                Uri.parse(
                  'https://apps.apple.com/jp/app/com.blue-waltz.my-gourmet',
                ),
              );
            }
          },
        );
      }
    } on Exception catch (e) {
      logger.e(e.toString());
      // 失敗したのでデフォルト値を使用
    }
  }
}
