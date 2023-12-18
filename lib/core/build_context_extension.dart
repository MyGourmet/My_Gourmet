import 'package:flutter/material.dart';

/// [BuildContext]の拡張メソッド
extension BuildContextExtension on BuildContext {
  ThemeData get theme => Theme.of(this);
  Size get deviceSize => MediaQuery.of(this).size;
  double get deviceWidth => deviceSize.width;
  double get deviceHeight => deviceSize.height;
}
