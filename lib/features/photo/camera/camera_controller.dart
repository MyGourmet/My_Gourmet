import 'dart:io';
import 'dart:typed_data';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:geolocator/geolocator.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:image/image.dart' as img;
import 'package:image_gallery_saver/image_gallery_saver.dart';
import 'package:my_gourmet/core/exception.dart';
import 'package:my_gourmet/features/auth/auth_controller.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:photo_manager/photo_manager.dart';

import '../../../core/logger.dart';
import '../../../core/photo_manager_service.dart';
import '../photo_repository.dart';

class CameraState {
  final File? capturedImage;
  final double? latitude;
  final double? longitude;
  final String? imageDate;
  final bool isTakingPicture;

  CameraState({
    this.capturedImage,
    this.latitude,
    this.longitude,
    this.imageDate,
    this.isTakingPicture = false,
  });

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
      if (!(await _ensurePermissions())) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('必要な権限が許可されていません。')),
        );
        return;
      }

      // 位置情報の取得
      double? latitude;
      double? longitude;
      try {
        var position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high,
        );
        latitude = position.latitude;
        longitude = position.longitude;
      } catch (e) {
        logger.e('位置情報の取得に失敗しました: $e');
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('位置情報の取得に失敗しました。')),
        );
      }

      // 画像をギャラリーに保存
      final result = await ImageGallerySaver.saveFile(image.path);
      logger.i('ギャラリーに画像を保存しました: $result');

      // 状態更新
      state = state.copyWith(
        capturedImage: File(image.path),
        latitude: latitude,
        longitude: longitude,
        imageDate: _formatDate(),
      );
    } catch (e) {
      logger.e('写真撮影エラー: $e');
    } finally {
      state = state.copyWith(isTakingPicture: false); // 撮影中フラグを解除
    }
  }

  // 権限の確認とリクエスト
  Future<bool> _ensurePermissions() async {
    // それぞれの権限状態を確認
    final storageStatus = await Permission.storage.status;
    final photosStatus = await Permission.photos.status;
    final locationStatus = await Permission.location.status;

    // 許可されていない権限に対してリクエスト
    if (!storageStatus.isGranted) {
      await Permission.storage.request();
    }
    if (!photosStatus.isGranted) {
      await Permission.photos.request();
    }
    if (!locationStatus.isGranted) {
      await Permission.location.request();
    }

    // todo iphone用追加
    // 再度権限の状態を確認して、すべてが許可されているかどうかを確認
    return (storageStatus.isGranted || photosStatus.isGranted) &&
        locationStatus.isGranted;
  }

  // 日付フォーマット
  String _formatDate() {
    final now = DateTime.now();
    return '${now.year}/${_twoDigits(now.month)}/${_twoDigits(now.day)}';
  }

  // 数字を2桁にするヘルパー関数
  String _twoDigits(int n) => n.toString().padLeft(2, '0');
}

// カメラコントローラ用のプロバイダー
final cameraControllerProvider =
    FutureProvider.autoDispose<CameraController>((ref) async {
  final cameras = await availableCameras();

  if (cameras.isEmpty) {
    throw CameraException('NoCameraAvailable', '利用可能なカメラが見つかりませんでした');
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
    return ref.read(photoManagerServiceProvider).getLatestPhotos();
  }

  Future<void> swipeRight({bool isFood = true}) async {
    // データがない時は何もしない
    final value = state.valueOrNull;
    if (value == null || state.asData == null) {
      return;
    }

    // エラーがある時は何もしない
    if (state.hasError) {
      return;
    }

    final photos = state.asData!.value;
    final photo = photos[0];
    // final length = photos.length;
    // IDのスラッシュをハイフンに置換
    final modifiedPhotoId = photo.id.replaceAll('/', '-');

    try {
      final userId = ref.read(userIdProvider);

      if (userId != null) {
        // 写真情報をサーバーに登録
        if (photo.longitude != null && photo.latitude != null) {
          await ref.read(photoRepositoryProvider).registerStoreInfo(
                photoId: modifiedPhotoId,
                userId: userId,
                latitude: photo.latitude,
                longitude: photo.longitude,
              );
        }

        final photoFile = await photo.file;
        if (photoFile != null) {
          final compressedData = await _compressImage(photoFile);
          if (compressedData != null) {
            await ref.read(photoRepositoryProvider).categorizeFood(
                  userId: userId,
                  photoId: modifiedPhotoId,
                  photoData: compressedData,
                );
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

    //todo
    // 最後の写真までスワイプした場合
    // ローディング
    state = const AsyncValue<List<AssetEntity>>.loading();
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
