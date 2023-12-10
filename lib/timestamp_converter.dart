import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'timestamp_converter.freezed.dart';

/// [_UnionTimestampConverter]用インスタンス
const timestampConverter = _UnionTimestampConverter();

/// [usesServerTime]がtrueの場合の[_UnionTimestampConverter]用インスタンス
const serverTimeTimestampConverter =
    _UnionTimestampConverter(usesServerTime: true);

/// [UnionTimestamp]型とFirestoreのタイムスタンプを相互変換するJsonConverter
///
/// [usesServerTime]はモデルクラス側から利用する際のインスタンス化時点では指定することが出来ないので、
/// [timestampConverter]又は[serverTimeTimestampConverter]経由で利用する
class _UnionTimestampConverter
    implements JsonConverter<UnionTimestamp, Object> {
  const _UnionTimestampConverter({this.usesServerTime = false});

  /// Firestoreへの書き込み時に、元々の値ではなくFirestoreのサーバー時間を用いるかどうか
  final bool usesServerTime;

  @override
  UnionTimestamp fromJson(Object json) {
    final timestamp = json as Timestamp;
    return UnionTimestamp.dateTime(timestamp.toDate());
  }

  @override
  Object toJson(UnionTimestamp unionTimestamp) => usesServerTime
      ? FieldValue.serverTimestamp()
      : unionTimestamp.map(
          dateTime: (unionDateTime) =>
              Timestamp.fromDate(unionDateTime.dateTime),
          serverTimestamp: (_) => FieldValue.serverTimestamp(),
        );
}

/// freezedのUnion Typeで定義した
/// Dartの[DateTime]型とFirestoreの[FieldValue.serverTimestampをまとめて扱うことができるクラス。
@freezed
class UnionTimestamp with _$UnionTimestamp {
  /// [DateTime]型用インスタンス
  const factory UnionTimestamp.dateTime(DateTime dateTime) = _UnionDateTime;

  /// [FieldValue.serverTimestamp用インスタンス
  const factory UnionTimestamp.serverTimestamp() = _UnionServerTimestamp;

  const UnionTimestamp._();

  /// UnionTimestamp.dateTimeのDateTimeを返す。
  /// serverTimestampの場合はnullを返す。
  DateTime? get dateTime =>
      mapOrNull(dateTime: (unionDateTime) => unionDateTime.dateTime);
}
