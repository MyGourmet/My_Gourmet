import 'package:flutter/material.dart';

/// [BuildContext]の拡張メソッド
extension BuildContextExtension on BuildContext {
  ThemeData get theme => Theme.of(this);
  TextTheme get textTheme => theme.textTheme;
  // TODO(masaki): screenSizeへ変更（デバイス自体というよりはディスプレイのサイズのため）
  Size get deviceSize => MediaQuery.of(this).size;
  double get deviceWidth => deviceSize.width;
  double get deviceHeight => deviceSize.height;
}
