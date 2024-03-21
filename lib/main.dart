import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'core/router.dart';
import 'core/themes.dart';

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
    return MaterialApp.router(
      theme: Themes.defaultTheme,
      routerConfig: ref.watch(routerProvider),
    );
  }
}
