import 'dart:async';
import 'dart:io';
import 'dart:typed_data';

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
