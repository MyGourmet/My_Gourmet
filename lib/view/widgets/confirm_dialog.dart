import 'package:flutter/material.dart';

import '../../core/build_context_extension.dart';

/// 確認用のダイアログ
class ConfirmDialog extends StatelessWidget {
  const ConfirmDialog._({
    required this.contentString,
    required this.titleString,
    required this.onConfirmed,
    required this.hasCancelButton,
    required this.shouldPopOnConfirmed,
  });

  /// ダイアログのタイトル
  final String titleString;

  /// ダイアログの中身
  final String contentString;

  /// 「はい」ボタン押下後の挙動
  final VoidCallback onConfirmed;

  /// 「いいえ」ボタンを表示するかどうか
  final bool hasCancelButton;

  /// [onConfirmed]完了後にダイアログを閉じるかどうか
  final bool shouldPopOnConfirmed;

  static Future<void> show(
    BuildContext context, {
    required String titleString,
    required String contentString,
    required VoidCallback onConfirmed,
    bool hasCancelButton = false,
    bool shouldPopOnConfirmed = true,
  }) async {
    await showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (_) {
        return ConfirmDialog._(
          titleString: titleString,
          contentString: contentString,
          onConfirmed: onConfirmed,
          hasCancelButton: hasCancelButton,
          shouldPopOnConfirmed: shouldPopOnConfirmed,
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
      ),
      title: Center(
        child: Text(
          titleString,
          style: context.textTheme.bodyMedium!.copyWith(
            color: Colors.white,
          ),
        ),
      ),
      content: Text(contentString),
      actions: [
        if (hasCancelButton)
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('いいえ'),
          ),
        TextButton(
          onPressed: () {
            onConfirmed();
            if (shouldPopOnConfirmed) {
              Navigator.of(context).pop();
            }
          },
          child: const Text('はい'),
        ),
      ],
    );
  }
}
