import 'package:flutter/material.dart';

class ConfirmDialog extends StatelessWidget {
  const ConfirmDialog._({
    required this.contentString,
    required this.titleString,
    required this.onConfirmed,
  });

  final String titleString;
  final String contentString;
  final VoidCallback onConfirmed;

  static Future<void> show(
    BuildContext context, {
    required String titleString,
    required String contentString,
    required VoidCallback onConfirmed,
  }) async {
    await showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (_) {
        return ConfirmDialog._(
          titleString: titleString,
          contentString: contentString,
          onConfirmed: onConfirmed,
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
        TextButton(
          onPressed: () => onConfirmed,
          child: const Text('はい'),
        ),
      ],
    );
  }
}
