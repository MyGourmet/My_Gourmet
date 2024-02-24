import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/app_colors.dart';
import '../features/auth/auth_controller.dart';
import 'widgets/confirm_dialog.dart';
import 'widgets/success_snack_bar.dart';

/// マイページ
class MyPage extends ConsumerWidget {
  const MyPage({super.key});

  static const routePath = '/my_page';

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      // ログインのリスト部分の設定
      body: Container(
        padding: const EdgeInsets.only(top: 50),
        color: AppColors.black,
        child: Column(
          children: [
            Expanded(
              child: ListView(
                children: [
                  ListTile(
                    onTap: () async {
                      await ConfirmDialog.show(
                        context,
                        hasCancelButton: true,
                        titleString: '注意',
                        contentString: '本当にアカウントを削除しますか？',
                        onConfirmed: () async {
                          await ref
                              .read(authControllerProvider)
                              .deleteUserAccount();
                          if (context.mounted) {
                            SuccessSnackBar.show(
                              context,
                              message: 'アカウントを削除しました',
                            );
                          }
                        },
                      );
                    },
                    title: const Text(
                      'アカウントを削除',
                      style: TextStyle(color: AppColors.white),
                    ),
                  ),
                  const Divider(
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
