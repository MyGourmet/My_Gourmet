import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'core/constants.dart';
import 'core/shared_preferences_service.dart';
import 'view/home_page.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp();
  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return MaterialApp(
      theme: ThemeData(fontFamily: kZenkakuGothicNew),
      home: const _SetUp(child: HomePage()),
    );
  }
}

/// 画面描画前に必要な処理を行うクラス
class _SetUp extends ConsumerStatefulWidget {
  const _SetUp({required this.child});

  final Widget child;

  @override
  ConsumerState<_SetUp> createState() => _SetUpState();
}

class _SetUpState extends ConsumerState<_SetUp> {
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _setUp().then(
        (value) => setState(() {
          isLoading = false;
        }),
      );
    });
  }

  Future<void> _setUp() async {
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
