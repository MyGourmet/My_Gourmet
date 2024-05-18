import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../view/home_page.dart';
import '../view/image_detail_page.dart';
import '../view/my_page.dart';
import '../view/root_page.dart';
import '../view/swipe_photo_page.dart';
import 'analytics_repository.dart';

final routerProvider = Provider(
  (ref) => GoRouter(
    initialLocation: HomePage.routePath,
    routes: [
      ShellRoute(
        builder: (context, state, child) => RootPage(child: child),
        routes: [
          GoRoute(
            name: HomePage.routeName,
            path: HomePage.routePath,
            builder: (context, state) => const HomePage(),
            routes: [
              GoRoute(
                name: ImageDetailPage.routeName,
                path: ImageDetailPage.routePath,
                builder: (context, state) {
                  final imagePath = state.extra! as String;
                  return ImageDetailPage(imagePath: imagePath);
                },
              ),
            ],
          ),
          GoRoute(
            name: MyPage.routeName,
            path: MyPage.routePath,
            builder: (context, state) => const MyPage(),
          ),
          GoRoute(
            name: SwipePhotoPage.routeName,
            path: SwipePhotoPage.routePath,
            builder: (context, state) => const SwipePhotoPage(),
          ),
        ],
      ),
    ],
    observers: [
      GoRouterObserver(analytics: ref.watch(analyticsRepository)),
    ],
  ),
);

class GoRouterObserver extends NavigatorObserver {
  GoRouterObserver({required this.analytics});
  final FirebaseAnalytics analytics;

  @override
  void didPush(Route<dynamic> route, Route<dynamic>? previousRoute) {
    if (route.settings.name != null) {
      analytics.setCurrentScreen(screenName: route.settings.name);
    }
  }
}
