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

  /// 最後の写真データを取得する
  Future<LastPhoto?> getLastPhoto() async {
    return (db.select(db.lastPhotos)
          ..limit(1))
        .getSingleOrNull();
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

    // 最後の写真id保存
    final lastPhotoModel = LastPhotosCompanion(
      id: Value(photo.id),
    );
    if ((await getLastPhoto()) != null) {
      // 更新
      await db.update(db.lastPhotos).write(lastPhotoModel);
    } else {
      // 登録
      await db.into(db.lastPhotos).insert(lastPhotoModel);
    }
  }
}
