import 'package:freezed_annotation/freezed_annotation.dart';

import '../../core/timestamp_converter.dart';

part 'store.freezed.dart';
part 'store.g.dart';

@freezed
class Store with _$Store {
  const factory Store({
    /// firestore上のドキュメントID
    @Default('') String id,

    /// 作成日時
    @timestampConverter
    @Default(UnionTimestamp.serverTimestamp())
    UnionTimestamp createdAt,

    /// 更新日時
    @serverTimestampConverter
    @Default(UnionTimestamp.serverTimestamp())
    UnionTimestamp updatedAt,

    /// FirebaseStorageに保存された（ストアの）写真のURL
    @Default([]) List<String> imageUrls,

    /// FirebaseStorageの(ストアの)name
    @Default('') String name,

    /// FirebaseStorageの（ストアの）電話番号
    @Default('') String phoneNumber,

    /// FirebaseStorageの（ストアの）URL
    @Default('') String website,

    /// FirebaseStorageの（ストアの）住所
    @Default('') String address,

    /// FirebaseStorageの（ストアの）休日
    @Default('') String holiday,

    /// 写真の撮影日時
    @timestampConverter
    @Default(UnionTimestamp.serverTimestamp())
    UnionTimestamp shotAt,
    @Default('') String storeId,
  }) = _Store;

  const Store._();

  factory Store.fromJson(Map<String, dynamic> json) => _$StoreFromJson(json);
}
