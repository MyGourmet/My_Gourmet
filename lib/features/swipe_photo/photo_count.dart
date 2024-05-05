import 'package:freezed_annotation/freezed_annotation.dart';

part 'photo_count.freezed.dart';

@freezed
class PhotoCount with _$PhotoCount {
  const factory PhotoCount({
    /// 現在の写真処理数
    required int current,

    /// 写真の合計数
    required int total,

  }) = _PhotoCount;

  const PhotoCount._();
}
