import 'package:flutter/material.dart';

import '../core/app_colors.dart';

/// マイページ
class MyPage extends StatefulWidget {
  const MyPage({super.key});

  static const routePath = '/my_page';

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
        color: AppColors.black,
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
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
