import 'dart:io';

import 'package:firebase_remote_config/firebase_remote_config.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:package_info/package_info.dart';
import 'package:url_launcher/url_launcher.dart';

import '../core/shared_preferences_service.dart';
import '../core/widgets/confirm_dialog.dart';
import '../core/widgets/navigation_frame.dart';
import 'auth/auth_repository.dart';
import 'onboarding_page.dart';

/// 全てのページの基盤となるページ
///
/// 初期化処理が終わり次第、[NavigationFrame]を描画する。
//class RootPage extends StatefulHookConsumerWidget {
class RootPage extends HookConsumerWidget {
  const RootPage({super.key, required this.child});

  final Widget child;
/*
  @override
  ConsumerState<RootPage> createState() => _RootPageState();
}

class _RootPageState extends ConsumerState<RootPage> {
  bool isLoading = true;
*/
/*
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
*/

/*
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
*/

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isLoading = useState(true); // Replaces isLoading in StatefulWidget

    //Future<void> _init() async {
    // ignore: unused_element
    Future<void> init(WidgetRef ref, BuildContext context) async {
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

    // useEffect replaces initState
    useEffect(() {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        //_init(ref, context).then((_) {
        init(ref, context).then((_) {
          isLoading.value = false;
        });
      });
      return null;
    }, [],);
  

    //return isLoading
    return isLoading.value
        ? const SizedBox.shrink()
        : NavigationFrame(
            child: Stack(
              children: [
                //widget.child,
                child,
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
