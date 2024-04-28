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
      type: DriftSqlType.string,
      requiredDuringInsert: true,
      defaultConstraints: GeneratedColumn.constraintIsAlways('UNIQUE'));
  static const VerificationMeta _pathMeta = const VerificationMeta('path');
  @override
  late final GeneratedColumn<String> path = GeneratedColumn<String>(
      'path', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _isFoodMeta = const VerificationMeta('isFood');
  @override
  late final GeneratedColumn<bool> isFood = GeneratedColumn<bool>(
      'is_food', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: true,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('CHECK ("is_food" IN (0, 1))'));
  @override
  List<GeneratedColumn> get $columns => [id, path, isFood];
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
    if (data.containsKey('is_food')) {
      context.handle(_isFoodMeta,
          isFood.isAcceptableOrUnknown(data['is_food']!, _isFoodMeta));
    } else if (isInserting) {
      context.missing(_isFoodMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => const {};
  @override
  Photo map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Photo(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      path: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}path'])!,
      isFood: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}is_food'])!,
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

  /// 食べ物かどうか
  final bool isFood;
  const Photo({required this.id, required this.path, required this.isFood});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['path'] = Variable<String>(path);
    map['is_food'] = Variable<bool>(isFood);
    return map;
  }

  PhotosCompanion toCompanion(bool nullToAbsent) {
    return PhotosCompanion(
      id: Value(id),
      path: Value(path),
      isFood: Value(isFood),
    );
  }

  factory Photo.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Photo(
      id: serializer.fromJson<String>(json['id']),
      path: serializer.fromJson<String>(json['path']),
      isFood: serializer.fromJson<bool>(json['isFood']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'path': serializer.toJson<String>(path),
      'isFood': serializer.toJson<bool>(isFood),
    };
  }

  Photo copyWith({String? id, String? path, bool? isFood}) => Photo(
        id: id ?? this.id,
        path: path ?? this.path,
        isFood: isFood ?? this.isFood,
      );
  @override
  String toString() {
    return (StringBuffer('Photo(')
          ..write('id: $id, ')
          ..write('path: $path, ')
          ..write('isFood: $isFood')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, path, isFood);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Photo &&
          other.id == this.id &&
          other.path == this.path &&
          other.isFood == this.isFood);
}

class PhotosCompanion extends UpdateCompanion<Photo> {
  final Value<String> id;
  final Value<String> path;
  final Value<bool> isFood;
  final Value<int> rowid;
  const PhotosCompanion({
    this.id = const Value.absent(),
    this.path = const Value.absent(),
    this.isFood = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  PhotosCompanion.insert({
    required String id,
    required String path,
    required bool isFood,
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        path = Value(path),
        isFood = Value(isFood);
  static Insertable<Photo> custom({
    Expression<String>? id,
    Expression<String>? path,
    Expression<bool>? isFood,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (path != null) 'path': path,
      if (isFood != null) 'is_food': isFood,
      if (rowid != null) 'rowid': rowid,
    });
  }

  PhotosCompanion copyWith(
      {Value<String>? id,
      Value<String>? path,
      Value<bool>? isFood,
      Value<int>? rowid}) {
    return PhotosCompanion(
      id: id ?? this.id,
      path: path ?? this.path,
      isFood: isFood ?? this.isFood,
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
    if (isFood.present) {
      map['is_food'] = Variable<bool>(isFood.value);
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
          ..write('isFood: $isFood, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  late final $PhotosTable photos = $PhotosTable(this);
  late final Index photoId =
      Index('photo_id', 'CREATE INDEX photo_id ON photos (id)');
  late final Index photoIsFood =
      Index('photo_is_food', 'CREATE INDEX photo_is_food ON photos (is_food)');
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities =>
      [photos, photoId, photoIsFood];
}
