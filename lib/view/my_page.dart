import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../features/auth/auth_controller.dart';
import 'widgets/confirm_dialog.dart';
import 'widgets/success_snack_bar.dart';

/// マイページ
class MyPage extends ConsumerWidget {
  const MyPage({super.key});

  static const routeName = 'my_page';
  static const routePath = '/my_page';

  // この後のプルリクで、下記のようにメソッドを切り出して呼び出す。
  // Future<void> _onButtonPressed() async {
  //   try {
  //     final result =
  //     await ref
  //        .read(authControllerProvider).signInWithGoogle();
  //     await ref
  //         .read(photoControllerProvider)
  //         .upsertClassifyPhotosStatus(userId: result.userId);
  //     });
  //     await ref.read(photoControllerProvider).uploadPhotos(
  //           accessToken: result.accessToken,
  //           userId: result.userId,
  //         );
  //   } on Exception catch (e) {
  //     // 例外が発生した場合、エラーメッセージを表示
  //     if (context.mounted) {
  //       ScaffoldMessenger.of(context).showSnackBar(
  //         SnackBar(content: Text(e.toString())),
  //       );
  //     }
  //   }
  // }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      // ログインのリスト部分の設定
      body: Container(
        padding: const EdgeInsets.only(top: 50),
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
                    title: const Text('   アカウントを削除'),
                  ),
                  const Divider(
                    thickness: 1,
                    indent: 20,
                    endIndent: 20,
                    color: Colors.white,
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
