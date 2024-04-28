import 'dart:io';

import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:permission_handler/permission_handler.dart';

/// パーミッションエラー判定用クラス
class PermissionException extends Error {}

/// [PermissionService]用プロバイダー
final permissionServiceProvider = Provider<PermissionService>(
  (ref) => PermissionService._(),
);

/// [Permission]を操作するクラス
class PermissionService {
  PermissionService._();

  /// 写真のパーミッションを取得する
  Future<bool> getPhotoPermission() async {
    if (Platform.isAndroid) {
      final info = await DeviceInfoPlugin().androidInfo;

      // sdkが33以上の場合
      if (info.version.sdkInt >= 33) {
        return (await Permission.photos.request()).isGranted;
      }

      return (await Permission.photos.request()).isGranted;
    } else {
      return (await Permission.photos.request()).isGranted;
    }
  }
}
