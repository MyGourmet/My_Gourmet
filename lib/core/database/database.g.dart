// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'database.dart';

// ignore_for_file: type=lint
class $PhotosTable extends Photos with TableInfo<$PhotosTable, Photo> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $PhotosTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _pathMeta = const VerificationMeta('path');
  @override
  late final GeneratedColumn<String> path = GeneratedColumn<String>(
      'path', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  @override
  List<GeneratedColumn> get $columns => [id, path];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'photos';
  @override
  VerificationContext validateIntegrity(Insertable<Photo> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('path')) {
      context.handle(
          _pathMeta, path.isAcceptableOrUnknown(data['path']!, _pathMeta));
    } else if (isInserting) {
      context.missing(_pathMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Photo map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Photo(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      path: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}path'])!,
    );
  }

  @override
  $PhotosTable createAlias(String alias) {
    return $PhotosTable(attachedDatabase, alias);
  }
}

class Photo extends DataClass implements Insertable<Photo> {
  /// 写真のid
  final String id;

  /// 写真のパス
  final String path;
  const Photo({required this.id, required this.path});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['path'] = Variable<String>(path);
    return map;
  }

  PhotosCompanion toCompanion(bool nullToAbsent) {
    return PhotosCompanion(
      id: Value(id),
      path: Value(path),
    );
  }

  factory Photo.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Photo(
      id: serializer.fromJson<String>(json['id']),
      path: serializer.fromJson<String>(json['path']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'path': serializer.toJson<String>(path),
    };
  }

  Photo copyWith({String? id, String? path}) => Photo(
        id: id ?? this.id,
        path: path ?? this.path,
      );
  @override
  String toString() {
    return (StringBuffer('Photo(')
          ..write('id: $id, ')
          ..write('path: $path')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, path);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Photo && other.id == this.id && other.path == this.path);
}

class PhotosCompanion extends UpdateCompanion<Photo> {
  final Value<String> id;
  final Value<String> path;
  final Value<int> rowid;
  const PhotosCompanion({
    this.id = const Value.absent(),
    this.path = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  PhotosCompanion.insert({
    required String id,
    required String path,
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        path = Value(path);
  static Insertable<Photo> custom({
    Expression<String>? id,
    Expression<String>? path,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (path != null) 'path': path,
      if (rowid != null) 'rowid': rowid,
    });
  }

  PhotosCompanion copyWith(
      {Value<String>? id, Value<String>? path, Value<int>? rowid}) {
    return PhotosCompanion(
      id: id ?? this.id,
      path: path ?? this.path,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (path.present) {
      map['path'] = Variable<String>(path.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('PhotosCompanion(')
          ..write('id: $id, ')
          ..write('path: $path, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $PhotoDetailsTable extends PhotoDetails
    with TableInfo<$PhotoDetailsTable, PhotoDetail> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $PhotoDetailsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _lastIdMeta = const VerificationMeta('lastId');
  @override
  late final GeneratedColumn<String> lastId = GeneratedColumn<String>(
      'last_id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _currentCountMeta =
      const VerificationMeta('currentCount');
  @override
  late final GeneratedColumn<int> currentCount = GeneratedColumn<int>(
      'current_count', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  @override
  List<GeneratedColumn> get $columns => [lastId, currentCount];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'photo_details';
  @override
  VerificationContext validateIntegrity(Insertable<PhotoDetail> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('last_id')) {
      context.handle(_lastIdMeta,
          lastId.isAcceptableOrUnknown(data['last_id']!, _lastIdMeta));
    } else if (isInserting) {
      context.missing(_lastIdMeta);
    }
    if (data.containsKey('current_count')) {
      context.handle(
          _currentCountMeta,
          currentCount.isAcceptableOrUnknown(
              data['current_count']!, _currentCountMeta));
    } else if (isInserting) {
      context.missing(_currentCountMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => const {};
  @override
  PhotoDetail map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return PhotoDetail(
      lastId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}last_id'])!,
      currentCount: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}current_count'])!,
    );
  }

  @override
  $PhotoDetailsTable createAlias(String alias) {
    return $PhotoDetailsTable(attachedDatabase, alias);
  }
}

class PhotoDetail extends DataClass implements Insertable<PhotoDetail> {
  /// 最後の写真id
  final String lastId;

  /// 現在の写真処理数
  final int currentCount;
  const PhotoDetail({required this.lastId, required this.currentCount});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['last_id'] = Variable<String>(lastId);
    map['current_count'] = Variable<int>(currentCount);
    return map;
  }

  PhotoDetailsCompanion toCompanion(bool nullToAbsent) {
    return PhotoDetailsCompanion(
      lastId: Value(lastId),
      currentCount: Value(currentCount),
    );
  }

  factory PhotoDetail.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return PhotoDetail(
      lastId: serializer.fromJson<String>(json['lastId']),
      currentCount: serializer.fromJson<int>(json['currentCount']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'lastId': serializer.toJson<String>(lastId),
      'currentCount': serializer.toJson<int>(currentCount),
    };
  }

  PhotoDetail copyWith({String? lastId, int? currentCount}) => PhotoDetail(
        lastId: lastId ?? this.lastId,
        currentCount: currentCount ?? this.currentCount,
      );
  @override
  String toString() {
    return (StringBuffer('PhotoDetail(')
          ..write('lastId: $lastId, ')
          ..write('currentCount: $currentCount')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(lastId, currentCount);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is PhotoDetail &&
          other.lastId == this.lastId &&
          other.currentCount == this.currentCount);
}

class PhotoDetailsCompanion extends UpdateCompanion<PhotoDetail> {
  final Value<String> lastId;
  final Value<int> currentCount;
  final Value<int> rowid;
  const PhotoDetailsCompanion({
    this.lastId = const Value.absent(),
    this.currentCount = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  PhotoDetailsCompanion.insert({
    required String lastId,
    required int currentCount,
    this.rowid = const Value.absent(),
  })  : lastId = Value(lastId),
        currentCount = Value(currentCount);
  static Insertable<PhotoDetail> custom({
    Expression<String>? lastId,
    Expression<int>? currentCount,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (lastId != null) 'last_id': lastId,
      if (currentCount != null) 'current_count': currentCount,
      if (rowid != null) 'rowid': rowid,
    });
  }

  PhotoDetailsCompanion copyWith(
      {Value<String>? lastId, Value<int>? currentCount, Value<int>? rowid}) {
    return PhotoDetailsCompanion(
      lastId: lastId ?? this.lastId,
      currentCount: currentCount ?? this.currentCount,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (lastId.present) {
      map['last_id'] = Variable<String>(lastId.value);
    }
    if (currentCount.present) {
      map['current_count'] = Variable<int>(currentCount.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('PhotoDetailsCompanion(')
          ..write('lastId: $lastId, ')
          ..write('currentCount: $currentCount, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  late final $PhotosTable photos = $PhotosTable(this);
  late final $PhotoDetailsTable photoDetails = $PhotoDetailsTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [photos, photoDetails];
}
