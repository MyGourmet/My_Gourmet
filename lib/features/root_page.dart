import 'dart:io';

import 'package:firebase_remote_config/firebase_remote_config.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
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
    await Future.wait([
      _checkBuildNumber(context), // contextは非同期関数のパラメータとして渡す
      ref.watch(sharedPreferencesServiceProvider).init(),
    ]);

    // 非同期処理後に `mounted` を再度確認
    if (!mounted) {
      return;
    }

    // TODO(anyone): リダイレクトを使って修正
    // サインイン状態かどうかを確認
    final isSignedIn = ref.read(authRepositoryProvider).isSignedIn();
    // サインインページに遷移
    if (!isSignedIn) {
      GoRouter.of(context).go(SignInPage.routePath);
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
