import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';

import '../../core/themes.dart';
import '../../features/my_page/my_page.dart';
import '../../features/onboarding_page.dart';
import '../../features/photo/gallery/gallery_page.dart';
import '../../features/photo/swipe_photo/classify_start_page.dart';
import '../../features/photo/swipe_photo/swipe_photo_page.dart';

/// [BottomNavigationBar]を用いてページ遷移を管理するクラス
class NavigationFrame extends ConsumerStatefulWidget {
  const NavigationFrame({super.key, required this.child});

  final Widget child;

  @override
  ConsumerState<NavigationFrame> createState() => _NavigationFrameState();
}

class _NavigationFrameState extends ConsumerState<NavigationFrame> {
  int _selectedIndex = 1;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final isOnboardingComplete = ref.read(isOnBoardingCompletedProvider);
      setState(() {
        // 初回起動時は画像追加ページ、　2回目以降はギャラリーページから起動させる。
        _selectedIndex = !isOnboardingComplete ? 0 : 1;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final isClassifyOnboardingCompleted =
        ref.watch(isClassifyOnboardingCompletedProvider);

    final isOnboardingComplete = ref.watch(isOnBoardingCompletedProvider);

    final itemWidth = MediaQuery.of(context).size.width / 3;
    final circleWidth = itemWidth * 0.8;

    return Scaffold(
      body: widget.child,
      bottomNavigationBar: DecoratedBox(
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(
            color: Themes.gray.shade900,
            width: 2,
            strokeAlign: BorderSide.strokeAlignOutside,
          ),
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(16),
            topRight: Radius.circular(16),
          ),
        ),
        child: ClipRRect(
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(16),
            topRight: Radius.circular(16),
          ),
          child: isOnboardingComplete
              ? Padding(
                  padding: const EdgeInsets.only(top: 4, bottom: 16),
                  child: Stack(
                    children: [
                      AnimatedPositioned(
                        duration: const Duration(milliseconds: 400),
                        curve: StickyCurve(), // カスタムCurveを使用
                        left: _selectedIndex * itemWidth +
                            (itemWidth - circleWidth) / 2,
                        child: Container(
                          width: circleWidth,
                          height: 72,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(36),
                            color: Themes.mainOrange,
                            border: Border.all(
                              color: Themes.gray.shade900,
                              width: 2,
                            ),
                          ),
                        ),
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          _buildNavItem(
                            icon: Icons.add,
                            label: '画像追加',
                            index: 0,
                            context: context,
                            isClassifyOnboardingCompleted:
                                isClassifyOnboardingCompleted,
                          ),
                          _buildNavItem(
                            icon: Icons.photo,
                            label: 'ギャラリー',
                            index: 1,
                            context: context,
                            isClassifyOnboardingCompleted:
                                isClassifyOnboardingCompleted,
                          ),
                          _buildNavItem(
                            icon: Icons.person,
                            label: 'マイページ',
                            index: 2,
                            context: context,
                            isClassifyOnboardingCompleted:
                                isClassifyOnboardingCompleted,
                          ),
                        ],
                      ),
                    ],
                  ),
                )
              : null,
        ),
      ),
    );
  }

  Widget _buildNavItem({
    required IconData icon,
    required String label,
    required int index,
    required BuildContext context,
    required bool isClassifyOnboardingCompleted,
  }) {
    final isSelected = index == _selectedIndex;
    final itemWidth = MediaQuery.of(context).size.width / 3;
    final circleWidth = itemWidth * 0.8;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          setState(() {
            _selectedIndex = index;
          });
          _onItemTapped(index, context, isClassifyOnboardingCompleted);
        },
        splashColor: Themes.mainOrange.withOpacity(0.1),
        borderRadius: BorderRadius.circular(36),
        child: SizedBox(
          width: itemWidth,
          height: 72,
          child: Stack(
            alignment: Alignment.center,
            children: [
              SizedBox(
                width: circleWidth,
                height: 72,
              ),
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  AnimatedSwitcher(
                    duration: const Duration(milliseconds: 300),
                    transitionBuilder:
                        (Widget child, Animation<double> animation) {
                      return FadeTransition(opacity: animation, child: child);
                    },
                    child: Icon(
                      icon,
                      key: ValueKey<bool>(isSelected),
                      color: isSelected ? Colors.white : Themes.gray[900],
                    ),
                  ),
                  const Gap(4),
                  AnimatedDefaultTextStyle(
                    duration: const Duration(milliseconds: 300),
                    style: TextStyle(
                      color: isSelected ? Colors.white : Themes.gray[900],
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                    child: Text(label),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _onItemTapped(
    int index,
    BuildContext context,
    bool isClassifyOnboardingCompleted,
  ) {
    switch (index) {
      case 0:
        context.go(
          isClassifyOnboardingCompleted
              ? SwipePhotoPage.routePath
              : ClassifyStartPage.routePath,
        );
      case 1:
        context.go(HomePage.routePath);
      case 2:
        context.go(MyPage.routePath);
    }
  }
}

class StickyCurve extends Curve {
  @override
  double transform(double t) {
    if (t < 0.5) {
      return 4 * t * t * t;
    } else {
      return 1 - math.pow(-2 * t + 2, 3) / 2;
    }
  }
}
