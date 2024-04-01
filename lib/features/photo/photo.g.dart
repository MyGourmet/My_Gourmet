// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'photo.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$PhotoImpl _$$PhotoImplFromJson(Map<String, dynamic> json) => _$PhotoImpl(
      id: json['id'] as String? ?? '',
      createdAt: json['createdAt'] == null
          ? const UnionTimestamp.serverTimestamp()
          : timestampConverter.fromJson(json['createdAt'] as Object),
      updatedAt: json['updatedAt'] == null
          ? const UnionTimestamp.serverTimestamp()
          : serverTimestampConverter.fromJson(json['updatedAt'] as Object),
      url: json['url'] as String? ?? '',
      userId: json['userId'] as String? ?? '',
      shotAt: json['shotAt'] == null
          ? const UnionTimestamp.serverTimestamp()
          : timestampConverter.fromJson(json['shotAt'] as Object),
      addressInfo: _$JsonConverterFromJson<GeoPoint, GeoPoint>(
          json['addressInfo'], const GeoPointConverter().fromJson),
    );

Map<String, dynamic> _$$PhotoImplToJson(_$PhotoImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'createdAt': timestampConverter.toJson(instance.createdAt),
      'updatedAt': serverTimestampConverter.toJson(instance.updatedAt),
      'url': instance.url,
      'userId': instance.userId,
      'shotAt': timestampConverter.toJson(instance.shotAt),
      'addressInfo': _$JsonConverterToJson<GeoPoint, GeoPoint>(
          instance.addressInfo, const GeoPointConverter().toJson),
    };

Value? _$JsonConverterFromJson<Json, Value>(
  Object? json,
  Value? Function(Json json) fromJson,
) =>
    json == null ? null : fromJson(json as Json);

Json? _$JsonConverterToJson<Json, Value>(
  Value? value,
  Json? Function(Value value) toJson,
) =>
    value == null ? null : toJson(value);
