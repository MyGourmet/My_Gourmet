import 'package:flutter/material.dart';

/// 動作の完了を知らせるスナックバー
class SuccessSnackBar extends SnackBar {
  SuccessSnackBar._({required String message})
      : super(
          content: Text(message),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        );

  static void show(
    BuildContext context, {
    required String message,
  }) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SuccessSnackBar._(message: message));
  }
}
