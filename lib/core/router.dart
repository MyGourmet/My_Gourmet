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
            builder: (context, state) => const HomePage(),
          ),
          GoRoute(
            path: MapPage.routePath,
            builder: (context, state) => const MapPage(),
          ),
          GoRoute(
            path: MyPage.routePath,
            builder: (context, state) => const MyPage(),
          ),
        ],
      ),
    ],
  ),
);
