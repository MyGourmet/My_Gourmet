import 'package:flutter/material.dart';
import 'package:my_gourmet/core/app_colors.dart';

class CustomButton extends StatelessWidget {
  const CustomButton._({
    required this.onPressed,
    required this.text,
    required this.color,
  });

  /// orangeのボタン
  factory CustomButton.orange({
    required void Function()? onPressed,
    required String text,
  }) {
    return CustomButton._(
      onPressed: onPressed,
      text: text,
      color: AppColors.orange,
    );
  }

  /// greyのボタン
  factory CustomButton.grey({
    required void Function()? onPressed,
    required String text,
  }) {
    return CustomButton._(
      onPressed: onPressed,
      text: text,
      color: AppColors.grey,
    );
  }

  final void Function()? onPressed;
  final String text;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: MediaQuery.of(context).size.width,
      child: FilledButton(
        onPressed: onPressed,
        style: OutlinedButton.styleFrom(
          backgroundColor: AppColors.orange,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
        child: Text(
          text,
          style: const TextStyle(
            color: AppColors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}
