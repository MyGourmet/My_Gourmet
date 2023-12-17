import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:my_gourmet/view/home_page.dart';

import 'core/shared_preferences_service.dart';
import 'firebase_options.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final container = ProviderContainer();
  await Future.wait([
    // Firebaseを初期化
    Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    ),
    // SharedPreferencesを初期化
    container.read(sharedPreferencesServiceProvider).init(),
  ]);
  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      theme: ThemeData(fontFamily: 'ZenkakuGothicNew'),
      home: HomePage(),
    );
  }
}
