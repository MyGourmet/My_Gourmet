import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../view/home_page.dart';
import '../view/map_page.dart';
import '../view/my_page.dart';
import '../view/root_page.dart';

final routerProvider = Provider(
  (ref) => GoRouter(
    initialLocation: HomePage.routePath,
    routes: [
      ShellRoute(
        builder: (context, state, child) => RootPage(child: child),
        routes: [
          GoRoute(
            path: HomePage.routePath,
            pageBuilder: (context, state) => const NoTransitionPage(
              child: HomePage(),
            ),
          ),
          GoRoute(
            path: MapPage.routePath,
            pageBuilder: (context, state) => const NoTransitionPage(
              child: MapPage(),
            ),
          ),
          GoRoute(
            path: MyPage.routePath,
            pageBuilder: (context, state) => const NoTransitionPage(
              child: MyPage(),
            ),
          ),
        ],
      ),
    ],
  ),
);
