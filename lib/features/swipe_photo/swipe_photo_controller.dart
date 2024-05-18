import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:photo_manager/photo_manager.dart';

import '../../core/local_photo_repository.dart';
import '../../core/permission_service.dart';
import '../../core/photo_manager_service.dart';
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

/// ご飯の登録数を取得するProvider
/// 分類完了後の 「追加された写真 ＋XXX枚」に使用
class _FoodPhotoCountNotifier extends AutoDisposeAsyncNotifier<int> {
  @override
  Future<int> build() async {
    // 取得できない場合はデフォルト値設定
    return ref.read(localPhotoRepositoryProvider).getPhotoCount();
  }
}

final foodPhotoCountProvider =
    AsyncNotifierProvider.autoDispose<_FoodPhotoCountNotifier, int>(
  _FoodPhotoCountNotifier.new,
);

/// 写真を取得するProvider
class _PhotoListNotifier extends AutoDisposeAsyncNotifier<List<AssetEntity>> {
  /// 初期処理
  @override
  Future<List<AssetEntity>> build() async {
    // パーミッション確認
    if (!await ref.read(permissionServiceProvider).getPhotoPermission()) {
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
    final length = photos.length;
    final dateTime = photos[index].createDateTime;

    try {
      // 写真登録
      await ref.read(localPhotoRepositoryProvider).savePhoto(
            photo: photos[index],
            isFood: isFood,
          );

      // カウント更新
      ref.read(photoCountProvider.notifier).updateCurrentCount();
    } on Exception catch (e, stacktrace) {
      state = AsyncValue.error(e, stacktrace);
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
            lastDate: dateTime,
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

  ///　強制リフレッシュ
  void forceRefresh() {
    state = const AsyncLoading<List<AssetEntity>>();
    ref.invalidateSelf();
  }
}

final photoListProvider =
    AsyncNotifierProvider.autoDispose<_PhotoListNotifier, List<AssetEntity>>(
  _PhotoListNotifier.new,
);
