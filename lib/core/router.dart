import 'dart:io';

import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../view/camera_detail_page.dart';
import '../view/camera_page.dart';
import '../view/classify_start_page.dart';
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
          ),
          GoRoute(
            name: MyPage.routeName,
            path: MyPage.routePath,
            builder: (context, state) => const MyPage(),
          ),
          GoRoute(
            name: CameraPage.routeName,
            path: CameraPage.routePath,
            builder: (context, state) => const CameraPage(),
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
        name: CameraDetailPage.routeName,
        path: CameraDetailPage.routePath,
        builder: (context, state) {
          final args = state.extra! as Map<String, dynamic>;
          final imageFile = args['imageFile'] as File;
          final imageDate = args['imageDate'] as String;

          return CameraDetailPage(
            imageFile: imageFile,
            imageDate: imageDate,
          );
        },
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
