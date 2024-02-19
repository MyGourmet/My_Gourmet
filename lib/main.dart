import 'dart:io';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_remote_config/firebase_remote_config.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:package_info/package_info.dart';
import 'package:url_launcher/url_launcher.dart';

import 'core/constants.dart';
import 'core/shared_preferences_service.dart';
import 'view/home_page.dart';
import 'view/widgets/confirm_dialog.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Future.wait([
    Firebase.initializeApp(),
    dotenv.load(),
  ]);
  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return MaterialApp(
      theme: ThemeData(fontFamily: kZenkakuGothicNew),
      home: const _AppInitializer(child: HomePage()),
    );
  }
}

/// 画面描画前に必要な初期化処理を行うクラス
class _AppInitializer extends ConsumerStatefulWidget {
  const _AppInitializer({required this.child});

  final Widget child;

  @override
  ConsumerState<_AppInitializer> createState() => _SetUpState();
}

class _SetUpState extends ConsumerState<_AppInitializer> {
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
        // SharedPreferencesを初期化
        ref.watch(sharedPreferencesServiceProvider).init(),
      ]);
    }
  }

  @override
  Widget build(BuildContext context) {
    return isLoading ? const SizedBox.shrink() : widget.child;
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
        onConfirmed: () async {
          if (Platform.isAndroid) {
            // TODO(masaki): Google Playにてアプリ作成後に動作確認
            await launchUrl(
              Uri.parse(
                'https://play.google.com/store/apps/details?id=com.example.my_gourmet',
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
