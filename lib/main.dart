import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'core/constants.dart';
import 'core/shared_preferences_service.dart';
import 'firebase_options.dart';
import 'view/home_page.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
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
    // SharedPreferencesを初期化
    final sharedPreferencesService =
        ref.watch(sharedPreferencesServiceProvider);
    await sharedPreferencesService.init();
  }

  @override
  Widget build(BuildContext context) {
    return isLoading ? const SizedBox.shrink() : widget.child;
  }
}
