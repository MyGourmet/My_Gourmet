// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'authed_user.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$AuthedUserImpl _$$AuthedUserImplFromJson(Map<String, dynamic> json) =>
    _$AuthedUserImpl(
      id: json['id'] as String? ?? '',
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
      uploadingStatus: $enumDecodeNullable(
              _$UploadingStatusEnumMap, json['uploadingStatus']) ??
          UploadingStatus.completed,
    );

Map<String, dynamic> _$$AuthedUserImplToJson(_$AuthedUserImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'createdAt': instance.createdAt.toIso8601String(),
      'updatedAt': instance.updatedAt.toIso8601String(),
      'uploadingStatus': _$UploadingStatusEnumMap[instance.uploadingStatus]!,
    };

const _$UploadingStatusEnumMap = {
  UploadingStatus.uploading: 'uploading',
  UploadingStatus.completed: 'completed',
  UploadingStatus.failed: 'failed',
};
