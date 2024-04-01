import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

import '../../core/geopoint_converter.dart';
import '../../core/timestamp_converter.dart';

part 'photo.freezed.dart';
part 'photo.g.dart';

@freezed
class Photo with _$Photo {
  const factory Photo({
    /// firestore上のドキュメントID
    @Default('') String id,

    /// 作成日時
    @timestampConverter @Default(UnionTimestamp.serverTimestamp()) UnionTimestamp createdAt,

    /// 更新日時
    @serverTimestampConverter @Default(UnionTimestamp.serverTimestamp()) UnionTimestamp updatedAt,

    /// FirebaseStorageに保存された写真のURL
    @Default('') String url,

    /// FirebaseStorageのドキュメントID
    @Default('') String userId,

    /// 写真の撮影日時
    @timestampConverter @Default(UnionTimestamp.serverTimestamp()) UnionTimestamp shotAt,

    /// 写真のジオポイント
    @GeoPointConverter() required GeoPoint? addressInfo,
  }) = _Photo;

  const Photo._();

  factory Photo.fromJson(Map<String, dynamic> json) => _$PhotoFromJson(json);
}
