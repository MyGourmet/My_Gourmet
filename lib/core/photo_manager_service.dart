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
  /// [lastDate] 最後の写真日付
  Future<List<AssetEntity>> getAllPhotos({DateTime? lastDate}) async {
    AdvancedCustomFilter filter;

    // 初回ロード
    if (lastDate == null) {
      // DBから写真情報を取得
      final photoDetail =
          await ref.read(localPhotoRepositoryProvider).getPhotoDetail();

      // PhotoManagerから写真数取得
      final totalCount = await PhotoManager.getAssetCount(
        type: RequestType.image,
      );
      // カウント更新
      ref
          .read(photoCountProvider.notifier)
          .updateCount(photoDetail?.currentCount ?? 0, totalCount);

      // 取得できた場合続きから写真を取得する
      if (photoDetail != null) {
        filter = _getPhotoDateFilter(
          DateTime.fromMillisecondsSinceEpoch(
            photoDetail.lastCreateDateSecond * 1000,
          ),
        );
      } else {
        filter = AdvancedCustomFilter();
      }
    } else {
      filter = _getPhotoDateFilter(lastDate);
    }

    // 写真を古い順に取得
    final albums = await PhotoManager.getAssetPathList(
      type: RequestType.image,
      filterOption: filter.addOrderBy(
        column: CustomColumns.base.createDate,
      ),
    );

    // 写真が取得できない場合
    if (albums.isEmpty) {
      // スワイプ完了
      if (ref.read(photoCountProvider) != null) {
        ref.read(photoCountProvider.notifier).complete();
      }

      return [];
    }

    // 100件取得(とりあえずの値なのであとで変更するかも)
    final photos = await albums[0].getAssetListPaged(page: 0, size: 100);

    return photos;
  }

  /// 写真日付でフィルタリングする
  /// [lastDate] 最後の写真日付
  AdvancedCustomFilter _getPhotoDateFilter(
    DateTime lastDate,
  ) {
    return AdvancedCustomFilter(
      where: [
        DateColumnWhereCondition(
          column: CustomColumns.base.createDate,
          operator: '>',
          value: lastDate,
        ),
      ],
    );
  }
}
