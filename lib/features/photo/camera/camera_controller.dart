import 'dart:io';
import 'dart:typed_data';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:geolocator/geolocator.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:image_gallery_saver/image_gallery_saver.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:photo_manager/photo_manager.dart';

import '../../../core/exception.dart';
import '../../../core/logger.dart';
import '../../../core/photo_manager_service.dart';
import '../../../core/widgets/date_utils.dart';
import '../../auth/auth_controller.dart';
import '../photo_repository.dart';

class CameraState {
  CameraState({
    this.capturedImage,
    this.latitude,
    this.longitude,
    this.imageDate,
    this.isTakingPicture = false,
  });
  final File? capturedImage;
  final double? latitude;
  final double? longitude;
  final String? imageDate;
  final bool isTakingPicture;

  CameraState copyWith({
    File? capturedImage,
    double? latitude,
    double? longitude,
    String? imageDate,
    bool? isTakingPicture,
  }) {
    return CameraState(
      capturedImage: capturedImage ?? this.capturedImage,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      imageDate: imageDate ?? this.imageDate,
      isTakingPicture: isTakingPicture ?? this.isTakingPicture,
    );
  }
}

class CameraStateNotifier extends StateNotifier<CameraState> {
  CameraStateNotifier(this.ref) : super(CameraState());

  final Ref ref;

  Future<void> takePictureAndSave(BuildContext context) async {
    state = state.copyWith(isTakingPicture: true); // 撮影中フラグをセット

    try {
      final controller = await ref.read(cameraControllerProvider.future);
      final image = await controller.takePicture();
      // 権限のリクエストをまとめて行う
      if (context.mounted) {
        if (!(await _ensurePermissions(context))) {
          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('設定画面で権限を許可してください。'),
                action: SnackBarAction(
                  label: '設定を開く',
                  onPressed: openAppSettings,
                ),
              ),
            );
          }
        }
        return;
      }

      // 画像をギャラリーに保存
      final result = await ImageGallerySaver.saveFile(image.path);
      logger.i('ギャラリーに画像を保存しました: $result');

      // 状態更新
      state = state.copyWith(
        capturedImage: File(image.path),
        imageDate: _formatDate(),
      );
    } on Exception catch (e) {
      logger.e('写真撮影エラー: $e');
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('設定画面で権限を許可してください。'),
            action: SnackBarAction(
              label: '設定を開く',
              onPressed: openAppSettings,
            ),
          ),
        );
      }
    } finally {
      state = state.copyWith(isTakingPicture: false); // 撮影中フラグを解除
    }
  }

  // 権限の確認とリクエスト
  Future<bool> _ensurePermissions(BuildContext context) async {
    while (true) {
      final cameraStatus = await Permission.camera.status;
      final storageStatus = await Permission.storage.status;
      final photosStatus = await Permission.photos.status;
      final locationStatus = await Permission.location.status;
      final microphoneStatus = await Permission.microphone.status;

      if (!storageStatus.isGranted ||
          !cameraStatus.isGranted ||
          !photosStatus.isGranted ||
          !locationStatus.isGranted ||
          !microphoneStatus.isGranted) {
        // いずれかの権限が拒否された場合、再度リクエスト
        final statuses = await [
          Permission.camera,
          Permission.storage,
          Permission.photos,
          Permission.location,
          Permission.microphone,
        ].request();

        if (statuses[Permission.camera]!.isPermanentlyDenied ||
            statuses[Permission.storage]!.isPermanentlyDenied ||
            statuses[Permission.photos]!.isPermanentlyDenied ||
            statuses[Permission.location]!.isPermanentlyDenied ||
            statuses[Permission.microphone]!.isPermanentlyDenied) {
          // 永久に拒否された場合、設定画面を表示する
          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('設定画面で権限を許可してください。'),
                action: SnackBarAction(
                  label: '設定を開く',
                  onPressed: openAppSettings,
                ),
              ),
            );
          }
          return false;
        }

        if (statuses[Permission.camera]!.isGranted &&
                statuses[Permission.storage]!.isGranted ||
            statuses[Permission.photos]!.isGranted &&
                statuses[Permission.location]!.isGranted &&
                statuses[Permission.microphone]!.isGranted) {
          return true;
        }
      } else {
        return true; // すべての権限が許可されている場合
      }
    }
  }

  // 日付フォーマット
  String _formatDate() {
    final now = DateTime.now();
    return formatDateTime.dateFmt.format(now);
  }
}

// カメラコントローラ用のプロバイダー
final cameraControllerProvider =
    FutureProvider.autoDispose<CameraController>((ref) async {
  final cameras = await availableCameras();

  if (cameras.isEmpty) {
    throw CameraException('NoCameraAvailable', '''
利用可能なカメラが見つかりませんでした''');
  }

  final camera = cameras.first;
  final controller = CameraController(
    camera,
    ResolutionPreset.medium,
  );

  ref.onDispose(controller.dispose);

  await controller.initialize();
  return controller;
});

// カメラ状態を管理するためのStateNotifierプロバイダー
final cameraStateProvider =
    StateNotifierProvider<CameraStateNotifier, CameraState>((ref) {
  return CameraStateNotifier(ref);
});

/// 写真リストを管理するプロバイダー
final photoListProvider =
    AsyncNotifierProvider.autoDispose<_PhotoListNotifier, List<AssetEntity>>(
  _PhotoListNotifier.new,
);

/// 写真を取得するProvider
class _PhotoListNotifier extends AutoDisposeAsyncNotifier<List<AssetEntity>> {
  /// 初期処理
  @override
  Future<List<AssetEntity>> build() async {
    // パーミッション確認
    final permission = await PhotoManager.requestPermissionExtend();
    if (!permission.isAuth && !permission.hasAccess) {
      throw PermissionException();
    }

    // 写真取得
    await PhotoManager.clearFileCache();
    await PhotoManager.getAssetPathList();
    return ref.read(photoManagerServiceProvider).getLatestPhotos();
  }

  Future<void> swipeRight({bool isFood = true}) async {
    final value = state.valueOrNull;
    if (value == null || state.asData == null) {
      return;
    }

    if (state.hasError) {
      return;
    }

    final photos = state.asData!.value;
    final photo = photos[0];

    final modifiedPhotoId = photo.id.replaceAll('/', '-');

    try {
      final userId = ref.read(userIdProvider);

      if (userId != null) {
        final position = await _getCurrentPosition();
        final latitude = position?.latitude;
        final longitude = position?.longitude;

        if (latitude != null && longitude != null) {
          await ref.read(photoRepositoryProvider).registerStoreInfo(
                photoId: modifiedPhotoId,
                userId: userId,
                latitude: latitude,
                longitude: longitude,
              );
          logger.i('写真情報をサーバーに登録しました: $modifiedPhotoId, '
              '緯度: $latitude, 経度: $longitude');
        }

        // 写真データの取得と圧縮
        final photoFile = await photo.file;
        if (photoFile != null) {
          final compressedData = await _compressImage(photoFile);
          if (compressedData != null) {
            await ref.read(photoRepositoryProvider).categorizeFood(
                  userId: userId,
                  photoId: modifiedPhotoId,
                  photoData: compressedData,
                );
            logger.i('圧縮写真データをサーバーに送信しました: $modifiedPhotoId');
          }
        }
      } else {
        throw Exception('User not signed in');
      }
    } on Exception catch (e, stacktrace) {
      state = AsyncValue.error(e, stacktrace);
      logger.e('写真の登録中にエラーが発生しました: $e');
      return;
    }

    // 最後の写真までスワイプした場合
    state = const AsyncValue<List<AssetEntity>>.loading();
  }

  // 位置情報の取得
  Future<Position?> _getCurrentPosition() async {
    try {
      const locationSettings = LocationSettings(
        accuracy: LocationAccuracy.high,
        distanceFilter: 100,
      );

      final position = await Geolocator.getCurrentPosition(
        locationSettings: locationSettings,
      );

      return position;
    } on Exception catch (e) {
      logger.e('位置情報の取得に失敗しました: $e');
      return null;
    }
  }

  /// 強制リフレッシュ
  void forceRefresh() {
    state = const AsyncLoading<List<AssetEntity>>();
    ref.invalidateSelf();
  }

  /// 画像を圧縮するメソッド
  Future<Uint8List?> _compressImage(File file) async {
    final result = await FlutterImageCompress.compressWithFile(
      file.absolute.path,
      minWidth: 256,
      minHeight: 256,
      quality: 85,
      keepExif: true,
    );
    return result;
  }
}
