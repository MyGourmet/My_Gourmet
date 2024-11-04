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

import '../../../core/date_utils.dart';
import '../../../core/exception.dart';
import '../../../core/photo_manager_service.dart';
import '../../auth/auth_controller.dart';
import '../photo_repository.dart';
import 'camera_state.dart';

class CameraStateNotifier extends StateNotifier<CameraState> {
  CameraStateNotifier(this.ref) : super(const CameraState());

  final Ref ref;

  Future<bool> takePictureAndSave(BuildContext context) async {
    debugPrint('takePictureAndSave: 撮影を開始します');
    state = state.copyWith(isTakingPicture: true); // 撮影中フラグをセット

    try {
      final controller = await ref.read(cameraControllerProvider.future);
      debugPrint('takePictureAndSave: カメラコントローラーを取得しました');

      final image = await controller.takePicture();
      debugPrint('takePictureAndSave: 撮影が完了しました');

      // 権限のリクエストをまとめて行う
      if (!(await _ensurePermissions())) {
        debugPrint('takePictureAndSave: 権限が不足しています');
        return false;
      }

      // 画像をギャラリーに保存
      final result = await ImageGallerySaver.saveFile(image.path);
      debugPrint('ギャラリーに画像を保存しました: $result');

      // 状態更新
      state = state.copyWith(
        capturedImage: File(image.path),
        imageDate: FormatDateTime.dateFmt.format(DateTime.now()),
      );
    } on Exception catch (e) {
      debugPrint('写真撮影エラー: $e');
      return false;
    } finally {
      state = state.copyWith(isTakingPicture: false); // 撮影中フラグを解除
      debugPrint('takePictureAndSave: 撮影中フラグを解除');
    }
    return true;
  }

  // 権限の確認とリクエスト
  Future<bool> _ensurePermissions() async {
    debugPrint('_ensurePermissions: 権限の確認を開始');

    final cameraStatus = await Permission.camera.status;
    final storageStatus = await Permission.storage.status;
    final photosStatus = await Permission.photos.status;
    final locationStatus = await Permission.location.status;
    final microphoneStatus = await Permission.microphone.status;

    debugPrint('Camera permission status: $cameraStatus');
    debugPrint('Storage permission status: $storageStatus');
    debugPrint('Photos permission status: $photosStatus');
    debugPrint('Location permission status: $locationStatus');
    debugPrint('Microphone permission status: $microphoneStatus');

    //アクセスが制限されている場合に処理を分岐
    if (photosStatus.isLimited || storageStatus.isLimited) {
      debugPrint('_ensurePermissions: 写真またはストレージのアクセスが制限されています');
      return false;
    }

    if (!storageStatus.isGranted ||
        !cameraStatus.isGranted ||
        !photosStatus.isGranted ||
        !locationStatus.isGranted ||
        !microphoneStatus.isGranted) {
      debugPrint('_ensurePermissions: 権限が不足しているためリクエストします');
      // いずれかの権限が拒否された場合、再度リクエスト
      final statuses = await [
        Permission.camera,
        Permission.storage,
        Permission.photos,
        Permission.location,
        Permission.microphone,
      ].request();

      debugPrint(
          'Camera permission after request: ${statuses[Permission.camera]}');
      debugPrint(
          'Storage permission after request: ${statuses[Permission.storage]}');
      debugPrint(
          'Photos permission after request: ${statuses[Permission.photos]}');
      debugPrint(
          'Location permission after request: ${statuses[Permission.location]}');
      debugPrint(
          'Microphone permission after request: ${statuses[Permission.microphone]}');

      if (statuses[Permission.camera]!.isPermanentlyDenied ||
          statuses[Permission.storage]!.isPermanentlyDenied ||
          statuses[Permission.photos]!.isPermanentlyDenied ||
          statuses[Permission.location]!.isPermanentlyDenied ||
          statuses[Permission.microphone]!.isPermanentlyDenied) {
        debugPrint('_ensurePermissions: いずれかの権限が永久に拒否されています');
        return false;
      }

      if (statuses[Permission.camera]!.isGranted &&
          statuses[Permission.storage]!.isGranted &&
          statuses[Permission.photos]!.isGranted &&
          statuses[Permission.location]!.isGranted &&
          statuses[Permission.microphone]!.isGranted) {
        debugPrint('_ensurePermissions: すべての権限が許可されました');
        return true;
      } else {
        debugPrint('_ensurePermissions: 権限が不足しています');
        return false;
      }
    } else {
      debugPrint('_ensurePermissions: すべての権限がすでに許可されています');
      return true;
    }
  }
}

// カメラコントローラ用のプロバイダー
final cameraControllerProvider =
    FutureProvider.autoDispose<CameraController>((ref) async {
  debugPrint('cameraControllerProvider: カメラコントローラを初期化中');

  final cameras = await availableCameras();

  if (cameras.isEmpty) {
    debugPrint('cameraControllerProvider: 利用可能なカメラが見つかりませんでした');
    throw CameraException('NoCameraAvailable', '利用可能なカメラが見つかりませんでした');
  }

  final camera = cameras.first;
  final controller = CameraController(
    camera,
    ResolutionPreset.medium,
  );

  ref.onDispose(() {
    controller.dispose();
    debugPrint('cameraControllerProvider: カメラコントローラを破棄しました');
  });

  await controller.initialize();
  debugPrint('cameraControllerProvider: カメラコントローラを初期化しました');
  return controller;
});

// カメラ状態を管理するためのStateNotifierプロバイダー
final cameraStateProvider =
    StateNotifierProvider<CameraStateNotifier, CameraState>((ref) {
  return CameraStateNotifier(ref);
});

/// 写真リストを管理するプロバイダー
final latestPhotoListProvider =
    AsyncNotifierProvider.autoDispose<_LatestPhotoNotifier, AssetEntity?>(
  _LatestPhotoNotifier.new,
);

/// 写真を取得するProvider
class _LatestPhotoNotifier extends AutoDisposeAsyncNotifier<AssetEntity?> {
  /// 初期処理
  @override
  Future<AssetEntity?> build() async {
    debugPrint('latestPhotoListProvider: 初期処理を開始します');
    // パーミッション確認
    final permission = await PhotoManager.requestPermissionExtend();
    debugPrint('latestPhotoListProvider: PhotoManager権限ステータス: $permission');

    if (!permission.isAuth && !permission.hasAccess) {
      throw PermissionException();
    }

    return null;
  }

  Future<void> swipeRight({bool isFood = true}) async {
    debugPrint('swipeRight: 処理を開始します');
    await PhotoManager.clearFileCache();
    await PhotoManager.getAssetPathList();
    final latestPhoto =
        await ref.read(photoManagerServiceProvider).getLatestPhoto();
    state = AsyncValue.data(latestPhoto);

    final value = state.valueOrNull;
    if (value == null || state.asData == null) {
      debugPrint('swipeRight: 最新の写真が取得できませんでした');
      return;
    }

    if (state.hasError) {
      debugPrint('swipeRight: エラーが発生しました');
      return;
    }

    final photo = state.asData!.value;

    final modifiedPhotoId = photo!.id.replaceAll('/', '-');
    debugPrint('swipeRight: 写真IDを修正しました - $modifiedPhotoId');

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
          debugPrint(
              '写真情報をサーバーに登録しました: $modifiedPhotoId, 緯度: $latitude, 経度: $longitude');
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
            debugPrint('圧縮写真データをサーバーに送信しました: $modifiedPhotoId');
          }
        }
      } else {
        debugPrint('swipeRight: ユーザーがサインインしていません');
        throw Exception('User not signed in');
      }
    } on Exception catch (e, stacktrace) {
      state = AsyncValue.error(e, stacktrace);
      debugPrint('写真の登録中にエラーが発生しました: $e');
      return;
    }

    // 最後の写真までスワイプした場合
    state = const AsyncValue<AssetEntity?>.loading();
  }

  // 位置情報の取得
  Future<Position?> _getCurrentPosition() async {
    debugPrint('_getCurrentPosition: 位置情報の取得を開始します');
    try {
      const locationSettings = LocationSettings(
        accuracy: LocationAccuracy.high,
        distanceFilter: 100,
      );

      final position = await Geolocator.getCurrentPosition(
        locationSettings: locationSettings,
      );

      debugPrint(
          '_getCurrentPosition: 位置情報を取得しました - 緯度: ${position.latitude}, 経度: ${position.longitude}');
      return position;
    } on Exception catch (e) {
      debugPrint('位置情報の取得に失敗しました: $e');
      return null;
    }
  }

  /// 強制リフレッシュ
  void forceRefresh() {
    debugPrint('forceRefresh: 強制リフレッシュを実行します');
    state = const AsyncLoading<AssetEntity?>();
    ref.invalidateSelf();
  }

  /// 画像を圧縮するメソッド
  Future<Uint8List?> _compressImage(File file) async {
    debugPrint('_compressImage: 画像の圧縮を開始します');
    final result = await FlutterImageCompress.compressWithFile(
      file.absolute.path,
      minWidth: 256,
      minHeight: 256,
      quality: 85,
      keepExif: true,
    );
    debugPrint('_compressImage: 画像の圧縮が完了しました');
    return result;
  }
}
