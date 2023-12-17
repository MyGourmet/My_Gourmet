// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'authed_user.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$AuthedUserImpl _$$AuthedUserImplFromJson(Map<String, dynamic> json) =>
    _$AuthedUserImpl(
      id: json['id'] as String? ?? '',
      createdAt: json['createdAt'] == null
          ? const UnionTimestamp.serverTimestamp()
          : timestampConverter.fromJson(json['createdAt'] as Object),
      updatedAt: json['updatedAt'] == null
          ? const UnionTimestamp.serverTimestamp()
          : serverTimeTimestampConverter.fromJson(json['updatedAt'] as Object),
      classifyPhotosStatus: $enumDecodeNullable(
              _$ClassifyPhotosStatusEnumMap, json['classifyPhotosStatus']) ??
          ClassifyPhotosStatus.readyForUse,
    );

Map<String, dynamic> _$$AuthedUserImplToJson(_$AuthedUserImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'createdAt': timestampConverter.toJson(instance.createdAt),
      'updatedAt': serverTimeTimestampConverter.toJson(instance.updatedAt),
      'classifyPhotosStatus':
          _$ClassifyPhotosStatusEnumMap[instance.classifyPhotosStatus]!,
    };

const _$ClassifyPhotosStatusEnumMap = {
  ClassifyPhotosStatus.processing: 'processing',
  ClassifyPhotosStatus.readyForUse: 'completed',
  ClassifyPhotosStatus.failed: 'failed',
};
