import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:photo_manager/photo_manager.dart';

import '../features/swipe_photo/swipe_photo_controller.dart';
import 'local_photo_repository.dart';

/// [PhotoService]用プロバイダー
final photoManagerServiceProvider = Provider<PhotoService>(
  PhotoService._,
);

/// [PhotoManager]を操作するクラス
class PhotoService {
  PhotoService._(this.ref);

  final Ref ref;

  /// 写真取得
  /// [lastId] 最後の写真id
  Future<List<AssetEntity>> getAllPhotos({String? lastId}) async {
    var filter = _getPhotoFilter();

    // 初回ロード
    if (lastId == null) {
      // DBから写真情報を取得
      final photoDetail =
          await ref.read(localPhotoRepositoryProvider).getPhotoDetail();

      // PhotoManagerから写真数取得
      final totalCount = await PhotoManager.getAssetCount(filterOption: filter);
      // カウント更新
      ref
          .read(photoCountProvider.notifier)
          .updateCount(photoDetail?.currentCount ?? 0, totalCount);

      // 取得できた場合続きから写真を取得する
      if (photoDetail != null) {
        filter = _getPhotoIdFilter(filter, photoDetail.lastId);
      }
    } else {
      filter = _getPhotoIdFilter(filter, lastId);
    }

    // 写真を古い順に取得
    final albums = await PhotoManager.getAssetPathList(
      filterOption: filter.addOrderBy(
        column: CustomColumns.base.id,
      ),
    );

    // 写真が取得できない場合 スワイプ完了もしくは、最初から写真がない
    if (albums.isEmpty) {
      if (ref.read(photoCountProvider) != null) {
        ref.read(photoCountProvider.notifier).complete();
      }
      return [];
    }

    // 100件取得(とりあえずの値なのであとで変更するかも)
    final photos = await albums[0].getAssetListPaged(page: 0, size: 100);

    return photos;
  }

  /// 画像でフィルタリングする
  AdvancedCustomFilter _getPhotoFilter() {
    return AdvancedCustomFilter().addWhereCondition(
      ColumnWhereCondition(
        column: CustomColumns.base.mediaType,
        operator: '=',
        value: '1',
      ),
    );
  }

  /// 写真idでフィルタリングする
  /// [filter] フィルター
  /// [lastId] 最後の写真id
  AdvancedCustomFilter _getPhotoIdFilter(
    AdvancedCustomFilter filter,
    String lastId,
  ) {
    return filter.addWhereCondition(
      ColumnWhereCondition(
        column: CustomColumns.base.id,
        operator: '>',
        value: lastId,
      ),
    );
  }
}
