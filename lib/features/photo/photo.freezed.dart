// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'photo.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

Photo _$PhotoFromJson(Map<String, dynamic> json) {
  return _Photo.fromJson(json);
}

/// @nodoc
mixin _$Photo {
  /// firestore上のドキュメントID
  String get id => throw _privateConstructorUsedError;

  /// 作成日時
  @timestampConverter
  UnionTimestamp get createdAt => throw _privateConstructorUsedError;

  /// 更新日時
  @serverTimestampConverter
  UnionTimestamp get updatedAt => throw _privateConstructorUsedError;

  /// FirebaseStorageに保存された写真の周辺店舗のIdリスト
  List<String> get areaStoreIds => throw _privateConstructorUsedError;

  /// FirebaseStorageに保存された写真のURL
  String get url => throw _privateConstructorUsedError;

  /// ローカルストレージに保存された画像のパス
  String get localImagePath => throw _privateConstructorUsedError;

  /// Firestoreに保存されたドキュメントのID
  String get firestoreDocumentId => throw _privateConstructorUsedError;

  /// geminiで推論した写真のカテゴリ
  /// ここをstringではなくてenumに変換して格納しておくと、
  /// Flutter上では型安全に扱えて想定外の実行時エラーが防げるため修正したい
  String get category => throw _privateConstructorUsedError;

  /// FirebaseStorageのドキュメントID
  String get userId => throw _privateConstructorUsedError;

  /// 写真の撮影日時
  @timestampConverter
  UnionTimestamp get shotAt => throw _privateConstructorUsedError;
  String get storeId => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $PhotoCopyWith<Photo> get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $PhotoCopyWith<$Res> {
  factory $PhotoCopyWith(Photo value, $Res Function(Photo) then) =
      _$PhotoCopyWithImpl<$Res, Photo>;
  @useResult
  $Res call(
      {String id,
      @timestampConverter UnionTimestamp createdAt,
      @serverTimestampConverter UnionTimestamp updatedAt,
      List<String> areaStoreIds,
      String url,
      String localImagePath,
      String firestoreDocumentId,
      String category,
      String userId,
      @timestampConverter UnionTimestamp shotAt,
      String storeId});

  $UnionTimestampCopyWith<$Res> get createdAt;
  $UnionTimestampCopyWith<$Res> get updatedAt;
  $UnionTimestampCopyWith<$Res> get shotAt;
}

/// @nodoc
class _$PhotoCopyWithImpl<$Res, $Val extends Photo>
    implements $PhotoCopyWith<$Res> {
  _$PhotoCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? createdAt = null,
    Object? updatedAt = null,
    Object? areaStoreIds = null,
    Object? url = null,
    Object? localImagePath = null,
    Object? firestoreDocumentId = null,
    Object? category = null,
    Object? userId = null,
    Object? shotAt = null,
    Object? storeId = null,
  }) {
    return _then(_value.copyWith(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      createdAt: null == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as UnionTimestamp,
      updatedAt: null == updatedAt
          ? _value.updatedAt
          : updatedAt // ignore: cast_nullable_to_non_nullable
              as UnionTimestamp,
      areaStoreIds: null == areaStoreIds
          ? _value.areaStoreIds
          : areaStoreIds // ignore: cast_nullable_to_non_nullable
              as List<String>,
      url: null == url
          ? _value.url
          : url // ignore: cast_nullable_to_non_nullable
              as String,
      localImagePath: null == localImagePath
          ? _value.localImagePath
          : localImagePath // ignore: cast_nullable_to_non_nullable
              as String,
      firestoreDocumentId: null == firestoreDocumentId
          ? _value.firestoreDocumentId
          : firestoreDocumentId // ignore: cast_nullable_to_non_nullable
              as String,
      category: null == category
          ? _value.category
          : category // ignore: cast_nullable_to_non_nullable
              as String,
      userId: null == userId
          ? _value.userId
          : userId // ignore: cast_nullable_to_non_nullable
              as String,
      shotAt: null == shotAt
          ? _value.shotAt
          : shotAt // ignore: cast_nullable_to_non_nullable
              as UnionTimestamp,
      storeId: null == storeId
          ? _value.storeId
          : storeId // ignore: cast_nullable_to_non_nullable
              as String,
    ) as $Val);
  }

  @override
  @pragma('vm:prefer-inline')
  $UnionTimestampCopyWith<$Res> get createdAt {
    return $UnionTimestampCopyWith<$Res>(_value.createdAt, (value) {
      return _then(_value.copyWith(createdAt: value) as $Val);
    });
  }

  @override
  @pragma('vm:prefer-inline')
  $UnionTimestampCopyWith<$Res> get updatedAt {
    return $UnionTimestampCopyWith<$Res>(_value.updatedAt, (value) {
      return _then(_value.copyWith(updatedAt: value) as $Val);
    });
  }

  @override
  @pragma('vm:prefer-inline')
  $UnionTimestampCopyWith<$Res> get shotAt {
    return $UnionTimestampCopyWith<$Res>(_value.shotAt, (value) {
      return _then(_value.copyWith(shotAt: value) as $Val);
    });
  }
}

/// @nodoc
abstract class _$$PhotoImplCopyWith<$Res> implements $PhotoCopyWith<$Res> {
  factory _$$PhotoImplCopyWith(
          _$PhotoImpl value, $Res Function(_$PhotoImpl) then) =
      __$$PhotoImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String id,
      @timestampConverter UnionTimestamp createdAt,
      @serverTimestampConverter UnionTimestamp updatedAt,
      List<String> areaStoreIds,
      String url,
      String localImagePath,
      String firestoreDocumentId,
      String category,
      String userId,
      @timestampConverter UnionTimestamp shotAt,
      String storeId});

  @override
  $UnionTimestampCopyWith<$Res> get createdAt;
  @override
  $UnionTimestampCopyWith<$Res> get updatedAt;
  @override
  $UnionTimestampCopyWith<$Res> get shotAt;
}

/// @nodoc
class __$$PhotoImplCopyWithImpl<$Res>
    extends _$PhotoCopyWithImpl<$Res, _$PhotoImpl>
    implements _$$PhotoImplCopyWith<$Res> {
  __$$PhotoImplCopyWithImpl(
      _$PhotoImpl _value, $Res Function(_$PhotoImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? createdAt = null,
    Object? updatedAt = null,
    Object? areaStoreIds = null,
    Object? url = null,
    Object? localImagePath = null,
    Object? firestoreDocumentId = null,
    Object? category = null,
    Object? userId = null,
    Object? shotAt = null,
    Object? storeId = null,
  }) {
    return _then(_$PhotoImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      createdAt: null == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as UnionTimestamp,
      updatedAt: null == updatedAt
          ? _value.updatedAt
          : updatedAt // ignore: cast_nullable_to_non_nullable
              as UnionTimestamp,
      areaStoreIds: null == areaStoreIds
          ? _value._areaStoreIds
          : areaStoreIds // ignore: cast_nullable_to_non_nullable
              as List<String>,
      url: null == url
          ? _value.url
          : url // ignore: cast_nullable_to_non_nullable
              as String,
      localImagePath: null == localImagePath
          ? _value.localImagePath
          : localImagePath // ignore: cast_nullable_to_non_nullable
              as String,
      firestoreDocumentId: null == firestoreDocumentId
          ? _value.firestoreDocumentId
          : firestoreDocumentId // ignore: cast_nullable_to_non_nullable
              as String,
      category: null == category
          ? _value.category
          : category // ignore: cast_nullable_to_non_nullable
              as String,
      userId: null == userId
          ? _value.userId
          : userId // ignore: cast_nullable_to_non_nullable
              as String,
      shotAt: null == shotAt
          ? _value.shotAt
          : shotAt // ignore: cast_nullable_to_non_nullable
              as UnionTimestamp,
      storeId: null == storeId
          ? _value.storeId
          : storeId // ignore: cast_nullable_to_non_nullable
              as String,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$PhotoImpl extends _Photo {
  const _$PhotoImpl(
      {this.id = '',
      @timestampConverter
      this.createdAt = const UnionTimestamp.serverTimestamp(),
      @serverTimestampConverter
      this.updatedAt = const UnionTimestamp.serverTimestamp(),
      final List<String> areaStoreIds = const <String>[],
      this.url = '',
      this.localImagePath = '',
      this.firestoreDocumentId = '',
      this.category = '',
      this.userId = '',
      @timestampConverter this.shotAt = const UnionTimestamp.serverTimestamp(),
      this.storeId = ''})
      : _areaStoreIds = areaStoreIds,
        super._();

  factory _$PhotoImpl.fromJson(Map<String, dynamic> json) =>
      _$$PhotoImplFromJson(json);

  /// firestore上のドキュメントID
  @override
  @JsonKey()
  final String id;

  /// 作成日時
  @override
  @JsonKey()
  @timestampConverter
  final UnionTimestamp createdAt;

  /// 更新日時
  @override
  @JsonKey()
  @serverTimestampConverter
  final UnionTimestamp updatedAt;

  /// FirebaseStorageに保存された写真の周辺店舗のIdリスト
  final List<String> _areaStoreIds;

  /// FirebaseStorageに保存された写真の周辺店舗のIdリスト
  @override
  @JsonKey()
  List<String> get areaStoreIds {
    if (_areaStoreIds is EqualUnmodifiableListView) return _areaStoreIds;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_areaStoreIds);
  }

  /// FirebaseStorageに保存された写真のURL
  @override
  @JsonKey()
  final String url;

  /// ローカルストレージに保存された画像のパス
  @override
  @JsonKey()
  final String localImagePath;

  /// Firestoreに保存されたドキュメントのID
  @override
  @JsonKey()
  final String firestoreDocumentId;

  /// geminiで推論した写真のカテゴリ
  /// ここをstringではなくてenumに変換して格納しておくと、
  /// Flutter上では型安全に扱えて想定外の実行時エラーが防げるため修正したい
  @override
  @JsonKey()
  final String category;

  /// FirebaseStorageのドキュメントID
  @override
  @JsonKey()
  final String userId;

  /// 写真の撮影日時
  @override
  @JsonKey()
  @timestampConverter
  final UnionTimestamp shotAt;
  @override
  @JsonKey()
  final String storeId;

  @override
  String toString() {
    return 'Photo(id: $id, createdAt: $createdAt, updatedAt: $updatedAt, areaStoreIds: $areaStoreIds, url: $url, localImagePath: $localImagePath, firestoreDocumentId: $firestoreDocumentId, category: $category, userId: $userId, shotAt: $shotAt, storeId: $storeId)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$PhotoImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt) &&
            (identical(other.updatedAt, updatedAt) ||
                other.updatedAt == updatedAt) &&
            const DeepCollectionEquality()
                .equals(other._areaStoreIds, _areaStoreIds) &&
            (identical(other.url, url) || other.url == url) &&
            (identical(other.localImagePath, localImagePath) ||
                other.localImagePath == localImagePath) &&
            (identical(other.firestoreDocumentId, firestoreDocumentId) ||
                other.firestoreDocumentId == firestoreDocumentId) &&
            (identical(other.category, category) ||
                other.category == category) &&
            (identical(other.userId, userId) || other.userId == userId) &&
            (identical(other.shotAt, shotAt) || other.shotAt == shotAt) &&
            (identical(other.storeId, storeId) || other.storeId == storeId));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      id,
      createdAt,
      updatedAt,
      const DeepCollectionEquality().hash(_areaStoreIds),
      url,
      localImagePath,
      firestoreDocumentId,
      category,
      userId,
      shotAt,
      storeId);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$PhotoImplCopyWith<_$PhotoImpl> get copyWith =>
      __$$PhotoImplCopyWithImpl<_$PhotoImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$PhotoImplToJson(
      this,
    );
  }
}

abstract class _Photo extends Photo {
  const factory _Photo(
      {final String id,
      @timestampConverter final UnionTimestamp createdAt,
      @serverTimestampConverter final UnionTimestamp updatedAt,
      final List<String> areaStoreIds,
      final String url,
      final String localImagePath,
      final String firestoreDocumentId,
      final String category,
      final String userId,
      @timestampConverter final UnionTimestamp shotAt,
      final String storeId}) = _$PhotoImpl;
  const _Photo._() : super._();

  factory _Photo.fromJson(Map<String, dynamic> json) = _$PhotoImpl.fromJson;

  @override

  /// firestore上のドキュメントID
  String get id;
  @override

  /// 作成日時
  @timestampConverter
  UnionTimestamp get createdAt;
  @override

  /// 更新日時
  @serverTimestampConverter
  UnionTimestamp get updatedAt;
  @override

  /// FirebaseStorageに保存された写真の周辺店舗のIdリスト
  List<String> get areaStoreIds;
  @override

  /// FirebaseStorageに保存された写真のURL
  String get url;
  @override

  /// ローカルストレージに保存された画像のパス
  String get localImagePath;
  @override

  /// Firestoreに保存されたドキュメントのID
  String get firestoreDocumentId;
  @override

  /// geminiで推論した写真のカテゴリ
  /// ここをstringではなくてenumに変換して格納しておくと、
  /// Flutter上では型安全に扱えて想定外の実行時エラーが防げるため修正したい
  String get category;
  @override

  /// FirebaseStorageのドキュメントID
  String get userId;
  @override

  /// 写真の撮影日時
  @timestampConverter
  UnionTimestamp get shotAt;
  @override
  String get storeId;
  @override
  @JsonKey(ignore: true)
  _$$PhotoImplCopyWith<_$PhotoImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
