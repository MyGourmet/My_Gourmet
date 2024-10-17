import 'package:flutter/material.dart';

import 'themes.dart';

class MyGourmetCard extends StatelessWidget {
  const MyGourmetCard({
    super.key,
    required this.child,
  });
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Colors.white,
      elevation: 5,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: Themes.gray[900]!),
      ),
      child: child,
    );
  }
}
