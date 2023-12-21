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
          : serverTimestampConverter.fromJson(json['updatedAt'] as Object),
      classifyPhotosStatus: json['classifyPhotosStatus'] == null
          ? ClassifyPhotosStatus.readyForUse
          : const ClassifyPhotosStatusConverter()
              .fromJson(json['classifyPhotosStatus'] as String),
    );

Map<String, dynamic> _$$AuthedUserImplToJson(_$AuthedUserImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'createdAt': timestampConverter.toJson(instance.createdAt),
      'updatedAt': serverTimestampConverter.toJson(instance.updatedAt),
      'classifyPhotosStatus': const ClassifyPhotosStatusConverter()
          .toJson(instance.classifyPhotosStatus),
    };
