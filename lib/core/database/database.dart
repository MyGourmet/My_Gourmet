import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';

part 'database.g.dart';

/// 写真テーブル
@DataClassName('Photo')
class Photos extends Table {
  /// 写真のid
  TextColumn get id => text()();

  /// 写真のパス
  TextColumn get path => text()();

  /// 主キー設定
  @override
  Set<Column> get primaryKey => {id};
}

/// 最後に処理した写真情報を保存するテーブル
@DataClassName('LastPhoto')
class LastPhotos extends Table {
  /// 写真のid
  TextColumn get id => text()();

  /// 主キー設定
  @override
  Set<Column> get primaryKey => {id};
}

/// DB設定
@DriftDatabase(tables: [Photos, LastPhotos])
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
