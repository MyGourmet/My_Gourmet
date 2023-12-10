import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

/// [_TimestampConverter]用インスタンス
const timestampConverter = _TimestampConverter();

/// [usesServerTime]がtrueの場合の[_TimestampConverter]用インスタンス
const serverTimestampConverter = _TimestampConverter(usesServerTime: true);

/// Flutterの[DateTime]型とFirestoreの[Timestamp]型を相互変換するJsonConverter
///
/// [usesServerTime]はモデルクラス側から利用する際のインスタンス化時点では指定することが出来ないので、
/// [timestampConverter]又は[serverTimestampConverter]経由で利用する
class _TimestampConverter implements JsonConverter<DateTime, Object> {
  const _TimestampConverter({this.usesServerTime = false});

  /// Firestoreへの書き込み時にFieldValue.serverTimestampを使用するかどうか
  final bool usesServerTime;

  @override
  DateTime fromJson(Object json) {
    final timestamp = json as Timestamp;
    return timestamp.toDate();
  }

  @override
  Object toJson(DateTime datetime) => usesServerTime
      ? FieldValue.serverTimestamp()
      : Timestamp.fromDate(datetime);
}
