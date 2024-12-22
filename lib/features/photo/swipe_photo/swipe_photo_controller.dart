import 'dart:async';
import 'dart:io';
import 'dart:typed_data';

import 'package:exif/exif.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:photo_manager/photo_manager.dart';

import '../../../core/exception.dart';
import '../../../core/local_photo_repository.dart';
import '../../../core/logger.dart';
import '../../../core/photo_manager_service.dart';
import '../../auth/auth_controller.dart';
import '../photo_repository.dart';
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
    // IDのスラッシュをハイフンに置換
    final modifiedPhotoId = photo.id.replaceAll('/', '-');

    try {
      final userId = ref.read(userIdProvider);

      if (userId != null) {
        //　TODO(kim): ローカルに写真を保存している処理が不要なものの、
        //　保存枚数などの処理は必要なので、処理の中身を後ほど修正する。
        // 写真登録
        await ref.read(localPhotoRepositoryProvider).savePhoto(
              photo: photo,
              isFood: isFood,
            );

        // 写真情報をサーバーに登録
        if (isFood) {
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
        }
      } else {
        throw Exception('User not signed in');
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

  // Future<void> swipeRight({bool isFood = true, required int index}) async {
  //   // データがない時は何もしない
  //   final value = state.valueOrNull;
  //   if (value == null || state.asData == null) {
  //     return;
  //   }
  //
  //   // エラーがある時は何もしない
  //   if (state.hasError) {
  //     return;
  //   }
  //
  //   final photos = state.asData!.value;
  //   final photo = photos[index];
  //   final length = photos.length;
  //   // IDのスラッシュをハイフンに置換
  //   final modifiedPhotoId = photo.id.replaceAll('/', '-');
  //
  //   try {
  //     final userId = ref.read(userIdProvider);
  //
  //     if (userId != null) {
  //       //　TODO(kim): ローカルに写真を保存している処理が不要なものの、
  //       //　保存枚数などの処理は必要なので、処理の中身を後ほど修正する。
  //       // 写真登録
  //       await ref.read(localPhotoRepositoryProvider).savePhoto(
  //             photo: photo,
  //             isFood: isFood,
  //           );
  //
  //       // 写真情報をサーバーに登録
  //       if (isFood) {
  //         if (photo.longitude != null && photo.latitude != null) {
  //           await ref.read(photoRepositoryProvider).registerStoreInfo(
  //                 photoId: modifiedPhotoId,
  //                 userId: userId,
  //                 latitude: photo.latitude,
  //                 longitude: photo.longitude,
  //               );
  //         }
  //
  //         final photoFile = await photo.file;
  //         if (photoFile != null) {
  //           final compressedData = await _compressImage(photoFile);
  //           if (compressedData != null) {
  //             await ref.read(photoRepositoryProvider).categorizeFood(
  //                   userId: userId,
  //                   photoId: modifiedPhotoId,
  //                   photoData: compressedData,
  //                 );
  //           }
  //         }
  //       }
  //     } else {
  //       throw Exception('User not signed in');
  //     }
  //     // カウント更新
  //     ref.read(photoCountProvider.notifier).updateCurrentCount();
  //   } on Exception catch (e, stacktrace) {
  //     state = AsyncValue.error(e, stacktrace);
  //     logger.e('Error loading next: $e');
  //     return;
  //   }
  //
  //   // 最後の写真までスワイプしていない場合
  //   if (index != length - 1) {
  //     return;
  //   }
  //
  //   // 最後の写真までスワイプした場合
  //   // ローディング
  //   state = const AsyncValue<List<AssetEntity>>.loading();
  //
  //   try {
  //     // 次の写真リストをDBから取得
  //     final results = await ref.read(photoManagerServiceProvider).getAllPhotos(
  //           lastEntity: photos[index],
  //         );
  //
  //     // 状態更新
  //     state = AsyncValue<List<AssetEntity>>.data([
  //       ...results,
  //     ]);
  //   } on Exception catch (e, stacktrace) {
  //     state = AsyncValue.error(e, stacktrace);
  //     return;
  //   }
  // }

  Future<void> swipeRight({
    required XFile image,
    bool isFood = true,
  }) async {
    // ID生成や圧縮の準備
    final modifiedPhotoId = image.path.split('/').last.replaceAll('/', '-');
    final userId = ref.read(userIdProvider);

    if (userId == null) {
      throw Exception('User not signed in');
    }

    try {
      if (isFood) {
        // 画像から位置情報を取得
        final location = await getImageLocation(image.path);

        // サーバーに位置情報を送信
        if (location != null) {
          await ref.read(photoRepositoryProvider).registerStoreInfo(
                photoId: modifiedPhotoId,
                userId: userId,
                latitude: location['latitude']!,
                longitude: location['longitude']!,
              );
        }

        // 画像ファイルの圧縮と送信
        final photoFile = File(image.path);
        final compressedData = await _compressImage(photoFile);

        if (compressedData != null) {
          await ref.read(photoRepositoryProvider).categorizeFood(
                userId: userId,
                photoId: modifiedPhotoId,
                photoData: compressedData,
              );
        }
      }
    } on Exception catch (e, stacktrace) {
      state = AsyncValue.error(e, stacktrace);
      logger.e('Error in swipeRight: $e');
    }
  }

  /// 画像から位置情報を取得
  Future<Map<String, double>?> getImageLocation(String imagePath) async {
    try {
      final file = File(imagePath);
      final bytes = await file.readAsBytes();

      // EXIFデータを解析
      final data = await readExifFromBytes(bytes);

      if (data == null || data.isEmpty) {
        return null; // EXIFデータがない場合
      }

      final gpsLatitude = data['GPS GPSLatitude']?.values.toList();
      final gpsLongitude = data['GPS GPSLongitude']?.values.toList();
      final gpsLatitudeRef = data['GPS GPSLatitudeRef']?.printable;
      final gpsLongitudeRef = data['GPS GPSLongitudeRef']?.printable;

      if (gpsLatitude != null && gpsLongitude != null) {
        final latitude = _convertToDecimal(
          gpsLatitude,
          gpsLatitudeRef == 'S' ? -1 : 1,
        );
        final longitude = _convertToDecimal(
          gpsLongitude,
          gpsLongitudeRef == 'W' ? -1 : 1,
        );

        return {
          'latitude': latitude,
          'longitude': longitude,
        };
      }
    } catch (e) {
      print('位置情報の取得に失敗しました: $e');
    }
    return null;
  }

  /// 度分秒を10進数に変換
  double _convertToDecimal(List<dynamic> values, int sign) {
    final degrees = _toDouble(values[0]);
    final minutes = _toDouble(values[1]) / 60;
    final seconds = _toDouble(values[2]) / 3600;
    return sign * (degrees + minutes + seconds);
  }

  /// EXIF値を`double`に変換
  double _toDouble(dynamic value) {
    if (value is! Ratio) {
      throw ArgumentError('値がRatio型ではありません: $value');
    }
    return value.numerator / value.denominator;
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

final photoListProvider =
    AsyncNotifierProvider.autoDispose<_PhotoListNotifier, List<AssetEntity>>(
  _PhotoListNotifier.new,
);
