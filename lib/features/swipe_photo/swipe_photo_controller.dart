import 'dart:async';
import 'dart:io';
import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:exif/exif.dart';
import 'package:flutter/material.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:photo_manager/photo_manager.dart';

import '../../core/exception.dart';
import '../../core/local_photo_repository.dart';
import '../../core/photo_manager_service.dart';
import '../../logger.dart';
import '../auth/auth_controller.dart';
import '../photo/photo_repository.dart';
import 'photo_count.dart';

/// 写真のカウントを管理するProvider
/// スワイプ画面の上部のカウントに使用
class _PhotoCountNotifier extends AutoDisposeNotifier<PhotoCount?> {
  @override
  PhotoCount? build() => null;

  /// カウント更新
  void updateCount(int current, int total) => state = PhotoCount(
        current: current,
        total: total,
      );

  /// 現在のカウント更新
  void updateCurrentCount() {
    state = state?.copyWith(
      current: (state?.current ?? 0) + 1,
    );
  }

  /// 完了
  void complete() {
    state = null;
  }
}

final photoCountProvider =
    NotifierProvider.autoDispose<_PhotoCountNotifier, PhotoCount?>(
  _PhotoCountNotifier.new,
);

/// グルメの登録数を取得するProvider
/// 分類完了後の 「追加された写真 ＋XXX枚」に使用
class _FoodPhotoTotalNotifier extends AutoDisposeAsyncNotifier<int> {
  @override
  Future<int> build() async {
    // 取得できない場合はデフォルト値設定
    return ref.read(localPhotoRepositoryProvider).getFoodPhotoTotal();
  }
}

final foodPhotoTotalProvider =
    AsyncNotifierProvider.autoDispose<_FoodPhotoTotalNotifier, int>(
  _FoodPhotoTotalNotifier.new,
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
    return ref.read(photoManagerServiceProvider).getAllPhotos();
  }

  /// 次の写真を取得する
  /// [isFood] 食べ物かどうか
  Future<void> loadNext({bool isFood = false, required int index}) async {
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
    final photo = photos[index];
    final length = photos.length;

    try {
      // 写真登録
      await ref.read(localPhotoRepositoryProvider).savePhoto(
            photo: photo,
            isFood: isFood,
          );

      // 写真情報をサーバーに登録
      if (isFood) {
        final result =
            await ref.read(authControllerProvider).signInWithGoogle();

        debugPrint('photo_managerパッケージ latitude: ${photo.latitude}');
        debugPrint('photo_managerパッケージ longitude: ${photo.longitude}');
        unawaited(
          photo.file.then((value) async {
            if (photo.longitude != null && photo.latitude != null) {
              // 写真情報をサーバーに登録
              debugPrint('registerStoreInfo start!!!');
              await ref.read(photoRepositoryProvider).registerStoreInfo(
                    photoId: photo.id,
                    userId: result.userId,
                    latitude: photo.latitude,
                    longitude: photo.longitude,
                  );
            }
          }),
        );

        unawaited(
          photo.file.then((value) async {
            // 画像を圧縮
            final compressedData = await _compressImage(value!);
            if (compressedData != null) {
              await ref.read(photoRepositoryProvider).categorizeFood(
                    userId: result.userId,
                    photoId: photo.id,
                    photoData: compressedData,
                  );
            }
          }),
        );
      }

      // カウント更新
      ref.read(photoCountProvider.notifier).updateCurrentCount();
    } on Exception catch (e, stacktrace) {
      state = AsyncValue.error(e, stacktrace);
      logger.e('Error loading next: $e');
      return;
    }

    // 最後の写真までスワイプしていない場合
    if (index != length - 1) {
      return;
    }

    // 最後の写真までスワイプした場合
    // ローディング
    state = const AsyncValue<List<AssetEntity>>.loading();

    try {
      // 次の写真リストをDBから取得
      final results = await ref.read(photoManagerServiceProvider).getAllPhotos(
            lastEntity: photos[index],
          );

      // 状態更新
      state = AsyncValue<List<AssetEntity>>.data([
        ...results,
      ]);
    } on Exception catch (e, stacktrace) {
      state = AsyncValue.error(e, stacktrace);
      return;
    }
  }

  /// 強制リフレッシュ
  void forceRefresh() {
    state = const AsyncLoading<List<AssetEntity>>();
    ref.invalidateSelf();
  }

  /// exifの位置情報を変換する
  GeoPoint? exifGPSToGeoPoint(Map<String, IfdTag> data) {
    try {
      if (!data.containsKey('GPS GPSLongitude')) {
        return null;
      }

      final gpsLatitude = data['GPS GPSLatitude'];
      final latitudeSignal = data['GPS GPSLatitudeRef']!.printable;
      final latitudeRation = gpsLatitude!.values.toList().cast<Ratio>();
      final latitudeValue = latitudeRation.map((item) {
        return item.numerator.toDouble() / item.denominator.toDouble();
      }).toList();
      var latitude = latitudeValue[0] +
          (latitudeValue[1] / 60) +
          (latitudeValue[2] / 3600);
      if (latitudeSignal == 'S') {
        latitude = -latitude;
      }

      final gpsLongitude = data['GPS GPSLongitude'];
      final longitudeSignal = data['GPS GPSLongitude']!.printable;
      final longitudeRation = gpsLongitude!.values.toList().cast<Ratio>();
      final longitudeValue = longitudeRation.map((item) {
        return item.numerator.toDouble() / item.denominator.toDouble();
      }).toList();
      var longitude = longitudeValue[0] +
          (longitudeValue[1] / 60) +
          (longitudeValue[2] / 3600);
      if (longitudeSignal == 'W') {
        longitude = -longitude;
      }

      return GeoPoint(latitude, longitude);
    } on Exception catch (_) {
      return null;
    }
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

final photoListProvider =
    AsyncNotifierProvider.autoDispose<_PhotoListNotifier, List<AssetEntity>>(
  _PhotoListNotifier.new,
);
