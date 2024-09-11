import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../features/auth/my_page.dart';
import '../features/auth/sign_in_page.dart';
import '../features/photo/gallery/gallery_page.dart';
import '../features/photo/image_detail/image_detail_page.dart';
import '../features/photo/swipe_photo/classify_start_page.dart';
import '../features/photo/swipe_photo/swipe_photo_page.dart';
import '../features/root_page.dart';
import 'analytics_repository.dart';

final routerProvider = Provider(
  (ref) => GoRouter(
    initialLocation: HomePage.routePath,
    routes: [
      ShellRoute(
        builder: (context, state, child) => RootPage(child: child),
        routes: [
          GoRoute(
            name: SignInPage.routeName,
            path: SignInPage.routePath,
            builder: (context, state) => const SignInPage(),
          ),
          GoRoute(
            name: HomePage.routeName,
            path: HomePage.routePath,
            builder: (context, state) => const HomePage(),
          ),
          GoRoute(
            name: MyPage.routeName,
            path: MyPage.routePath,
            builder: (context, state) => const MyPage(),
          ),
          GoRoute(
            name: ClassifyStartPage.routeName,
            path: ClassifyStartPage.routePath,
            builder: (context, state) => const ClassifyStartPage(),
          ),
          GoRoute(
            name: SwipePhotoPage.routeName,
            path: SwipePhotoPage.routePath,
            builder: (context, state) => const SwipePhotoPage(),
          ),
        ],
      ),
      GoRoute(
        name: ImageDetailPage.routeName,
        path: ImageDetailPage.routePath,
        builder: (context, state) {
          final args = state.extra! as Map<String, dynamic>;
          return ImageDetailPage(
            index: args['index'] as int,
            photoId: args['photoId'] as String,
          );
        },
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
      analytics.logScreenView(screenName: route.settings.name);
    }
  }
}
