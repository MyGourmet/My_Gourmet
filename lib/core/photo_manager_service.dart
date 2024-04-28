import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:photo_manager/photo_manager.dart';

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
    var filter = AdvancedCustomFilter().addWhereCondition(
      // 画像でフィルタリング
      ColumnWhereCondition(
        column: CustomColumns.base.mediaType,
        operator: '=',
        value: '1',
      ),
    );

    // 初回ロード
    if (lastId == null) {
      // DBから最後の写真データを取得
      final lastPhoto =
          await ref.read(localPhotoRepositoryProvider).getLastPhoto();

      // 取得できた場合続きから写真を取得する
      if (lastPhoto != null) {
        filter = _getPhotoIdFilter(filter, lastPhoto.id);
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

    if (albums.isEmpty) {
      return [];
    }

    // 100件取得(とりあえずの値なのであとで変更するかも)
    final photos = await albums[0].getAssetListPaged(page: 0, size: 100);

    return photos;
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
