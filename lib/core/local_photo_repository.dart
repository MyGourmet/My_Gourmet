import 'package:drift/drift.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:photo_manager/photo_manager.dart';
import '../../core/database/database.dart';

/// [LocalPhotoRepository]用プロバイダー
final localPhotoRepositoryProvider =
    Provider((ref) => LocalPhotoRepository._());

/// DBを操作するクラス
class LocalPhotoRepository {
  LocalPhotoRepository._();

  /// DBインスタンス生成
  final AppDatabase db = AppDatabase();

  /// 写真情報を取得する
  Future<PhotoDetail?> getPhotoDetail() async {
    return (db.select(db.photoDetails)..limit(1)).getSingleOrNull();
  }

  /// 写真数を取得する
  Future<int> getPhotoCount() async {
    final countExpression = countAll();
    final query = db.selectOnly(db.photos)..addColumns([countExpression]);
    final row = await query.getSingle();
    return row.rawData.data.values.first as int;
  }

  /// 写真データを保存する
  /// [photo] 写真データ
  /// [isFood] 食べ物かどうか
  Future<void> savePhoto({
    required AssetEntity photo,
    required bool isFood,
  }) async {
    final file = await photo.file;
    // 飯の場合写真データ保存
    if (isFood && file != null) {
      final photoModel = PhotosCompanion(
        id: Value(photo.id),
        path: Value(file.path),
      );
      await db.into(db.photos).insertOnConflictUpdate(photoModel);
    }

    // 写真情報保存
    final photoDetail = await getPhotoDetail();
    final lastPhotoModel = PhotoDetailsCompanion(
      lastId: Value(photo.id),
      lastCreateDateSecond: Value(photo.createDateSecond!),
      currentCount:
          Value(photoDetail != null ? photoDetail.currentCount + 1 : 1),
    );
    if (photoDetail != null) {
      // 更新
      await db.update(db.photoDetails).write(lastPhotoModel);
    } else {
      // 登録
      await db.into(db.photoDetails).insert(lastPhotoModel);
    }
  }
}
