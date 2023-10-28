import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:my_gourmet/home_page.dart';

import 'auth_util.dart';
import 'firebase_options.dart';

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
    return FutureBuilder(
      future: _getUser(ref),
      builder: (context, AsyncSnapshot<String> userIdSnapshot) {
        if (userIdSnapshot.connectionState == ConnectionState.done) {
          if (userIdSnapshot.hasError) {
            return const Center(
              child: Text('ユーザー情報の取得中にエラーが発生しました'),
            );
          }
          final String userId = userIdSnapshot.data ?? ''; // ユーザーIDを取得
          return MaterialApp(
            home: HomePage(userId: userId),
          );
        } else {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }
      },
    );
  }

  Future<String> _getUser(WidgetRef ref) async {
    final userId = await ref.read(authUtilProvider).getCurrentUserId();
    return userId ?? 'user_empty';
  }
}
