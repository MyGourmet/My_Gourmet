import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../core/app_colors.dart';
import 'home_page.dart';
import 'my_page.dart';

/// 全てのページの基盤となるページ
class RootPage extends StatelessWidget {
  const RootPage({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: child,
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _calcSelectedIndex(context),
        onTap: (int index) => _onItemTapped(index, context),
        // TODO(masaki): 以下、MyPageからそのまま転載している色やレイアウトを要調整
        backgroundColor: AppColors.black.withOpacity(0.9),
        fixedColor: const Color(0xFFEF913A),
        unselectedItemColor: const Color(0xFFEF913A).withOpacity(
          0.6,
        ),
        unselectedFontSize: 0,
        items: const [
          BottomNavigationBarItem(
            icon: Padding(
              padding: EdgeInsets.only(top: 10), // 上側の余白を設定
              child: Icon(
                Icons.photo,
                size: 40,
              ),
            ),
            label: '',
          ),
          BottomNavigationBarItem(
            icon: Padding(
              padding: EdgeInsets.only(top: 10),
              child: Icon(
                Icons.person,
                size: 40,
              ),
            ),
            label: '',
          ),
        ],
      ),
    );
  }

  int _calcSelectedIndex(BuildContext context) {
    final location = GoRouterState.of(context).uri.toString();
    return switch (location) {
      HomePage.routePath => 0,
      MyPage.routePath => 1,
      String() => throw UnimplementedError(),
    };
  }

  void _onItemTapped(int index, BuildContext context) {
    switch (index) {
      case 0:
        context.go(HomePage.routePath);
      case 1:
        context.go(MyPage.routePath);
    }
  }
}
