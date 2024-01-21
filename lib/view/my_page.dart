import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/app_colors.dart';

/// ログイン用画面
///

class MyPage extends StatefulWidget {
  const MyPage({super.key, required this.title});

  final String title;

  @override
  State<MyPage> createState() => _MyPageState();
}

class _MyPageState extends State<MyPage> {

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      // ログインのリスト部分の設定
      body: Container(
        padding: const EdgeInsets.only(top: 50),
        color:AppColors.black,
        child: Column(
          children: [
            Expanded(
              child: ListView(
                children: const [
                  ListTile(
                    title: Text(
                      'ログイン',
                      style: TextStyle(color: AppColors.white),
                    ),
                  ),
                  Divider(
                    thickness: 1,
                    indent: 20,
                    endIndent: 20,
                    color: AppColors.white,
                  ),
                  ListTile(
                    title: Text(
                      'ログアウト',
                      style: TextStyle(color: AppColors.white),
                    ),
                  ),
                  Divider(
                    thickness: 1,
                    indent: 20,
                    endIndent: 20,
                    color: AppColors.white,
                  ),
                  ListTile(
                    title: Text(
                      'アカウントを削除',
                      style: TextStyle(color: AppColors.white),
                    ),
                  ),
                  Divider(
                    thickness: 1,
                    indent: 20,
                    endIndent: 20,
                    color: AppColors.white,
                  ),
                  ListTile(
                    title: Text(
                        'xxxxx',
                        style: TextStyle(color: AppColors.white),
                    ),
                  ),
                  Divider(
                    thickness: 1,
                    indent: 20,
                    endIndent: 20,
                    color: AppColors.white,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),

      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: AppColors.black.withOpacity(0.9),
        fixedColor: const Color(0xFFEF913A),
        unselectedItemColor: Color(0xFFEF913A).withOpacity(0.6), //選んでない物の色        unselectedFontSize: 0, // 非選択時のフォントサイズを0に設定
        items: [
          BottomNavigationBarItem(
            icon: Padding(
              padding: EdgeInsets.only(top: 10), // 上側の余白を設定
              child: Icon(
                Icons.photo,
                size: 40, // アイコンのサイズを設定
              ),
            ),
            label: '',
          ),
          BottomNavigationBarItem(
            icon: Padding(
              padding: EdgeInsets.only(top: 10), // 上側の余白を設定
              child: Icon(
                Icons.person,
                size: 40, // アイコンのサイズを設定
              ),
            ),
            label: '',
          ),
        ],
      ),
    );
  }
}
