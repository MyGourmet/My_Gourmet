import 'package:flutter/material.dart';

class ConfirmDialog extends StatelessWidget {
  const ConfirmDialog._({
    required this.contentString,
    required this.titleString,
    required this.onConfirmed,
    required this.hasCancelButton,
    required this.shouldPopOnConfirmed,
  });

  final String titleString;
  final String contentString;
  final VoidCallback onConfirmed;
  final bool hasCancelButton;

  /// ボタン押下後にダイアログを閉じるかどうか
  final bool shouldPopOnConfirmed;

  static Future<void> show(
    BuildContext context, {
    required String titleString,
    required String contentString,
    required VoidCallback onConfirmed,
    bool hasCancelButton = false,
    bool shouldPopOnConfirmed = true,
  }) async {
    await showDialog<bool>(
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
      title: Center(child: Text(titleString)),
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
