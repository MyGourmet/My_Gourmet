// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'authed_user.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$AuthedUserImpl _$$AuthedUserImplFromJson(Map<String, dynamic> json) =>
    _$AuthedUserImpl(
      id: json['id'] as String? ?? '',
      createdAt: timestampConverter.fromJson(json['createdAt'] as Object),
      updatedAt: serverTimestampConverter.fromJson(json['updatedAt'] as Object),
      uploadingStatus: $enumDecodeNullable(
              _$UploadingStatusEnumMap, json['uploadingStatus']) ??
          UploadingStatus.completed,
    );

Map<String, dynamic> _$$AuthedUserImplToJson(_$AuthedUserImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'createdAt': timestampConverter.toJson(instance.createdAt),
      'updatedAt': serverTimestampConverter.toJson(instance.updatedAt),
      'uploadingStatus': _$UploadingStatusEnumMap[instance.uploadingStatus]!,
    };

const _$UploadingStatusEnumMap = {
  UploadingStatus.uploading: 'uploading',
  UploadingStatus.completed: 'completed',
  UploadingStatus.failed: 'failed',
};
