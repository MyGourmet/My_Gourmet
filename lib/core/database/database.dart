import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';

part 'database.g.dart';

/// 写真テーブル
@DataClassName('Photo')
@TableIndex(name: 'photo_id', columns: {#id})
@TableIndex(name: 'photo_is_food', columns: {#isFood})
class Photos extends Table {
  // IntColumn get id => integer().autoIncrement()();

  /// 写真のid
  TextColumn get id => text().unique()();

  /// 写真のパス
  TextColumn get path => text()();

// DateTimeColumn get date => dateTime()();
  /// 食べ物かどうか
  BoolColumn get isFood => boolean()();
}

/// DB設定
@DriftDatabase(tables: [Photos])
class AppDatabase extends _$AppDatabase {
  // 引数なしのコンストラクタで_openConnectionを直接使用
  AppDatabase() : super(_openConnection());

  @override
  int get schemaVersion => 1;
}

/// コネクション生成
LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    final dbFolder = await getApplicationDocumentsDirectory();
    final file = File(join(dbFolder.path, 'db.sqlite'));
    return NativeDatabase(file);
  });
}

/// DBインスタンス生成
final AppDatabase appDatabase = AppDatabase();

/// DBインスタンス取得
AppDatabase getAppDatabaseInstance() {
  return appDatabase;
}
