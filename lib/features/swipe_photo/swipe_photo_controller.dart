import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:photo_manager/photo_manager.dart';

import '../../core/local_photo_repository.dart';
import '../../core/permission_service.dart';
import '../../core/photo_manager_service.dart';

/// 写真のインデックスを管理するProvider
class _PhotoIndexNotifier extends AutoDisposeNotifier<int> {
  @override
  int build() => 0;

  /// indexプラス
  void increment() => state++;

  /// indexクリア
  void clear() => state = 0;
}

final photoIndexProvider =
    NotifierProvider.autoDispose<_PhotoIndexNotifier, int>(
  _PhotoIndexNotifier.new,
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
  Future<void> loadNext({bool isFood = false}) async {
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
    final index = ref.read(photoIndexProvider);
    final id = photos[index].id;

    try {
      // 写真登録
      await ref.read(localPhotoRepositoryProvider).savePhoto(
            photo: photos[index],
            isFood: isFood,
          );
    } on Exception catch (e, stacktrace) {
      state = AsyncValue.error(e, stacktrace);
      return;
    }

    // 写真のindex更新
    ref.read(photoIndexProvider.notifier).increment();

    // 最後の写真までスワイプしていない場合
    if (index != length - 1) {
      return;
    }

    // 最後の写真までスワイプした場合
    // ローディング
    state = const AsyncValue<List<AssetEntity>>.loading();

    try {
      // 次の写真リストをDBから取得
      final results =
          await ref.read(photoManagerServiceProvider).getAllPhotos(lastId: id);

      // indexクリア
      ref.read(photoIndexProvider.notifier).clear();

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
