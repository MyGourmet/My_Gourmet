import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:my_gourmet/home_page.dart';

import 'auth_util.dart';
import 'firebase_options.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: _getUser(),
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

  Future<String> _getUser() async {
    final userId = await AuthUtil.instance.getCurrentUserId();
    return userId ?? 'user_empty';
  }
}
