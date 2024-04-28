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
  Future<Photo?> getLastPhoto() async {
    return (db.select(db.photos)
          ..orderBy([
            (t) => OrderingTerm(expression: t.id, mode: OrderingMode.desc),
          ])
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
    if (file != null) {
      final photoModel = PhotosCompanion(
        id: Value(photo.id),
        path: Value(file.path),
        // date: Value(DateTime.now()),
        isFood: Value(isFood),
      );
      await db.into(db.photos).insert(photoModel);
    }
  }
}
