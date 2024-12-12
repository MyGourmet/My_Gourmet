import 'package:freezed_annotation/freezed_annotation.dart';

import '../../core/timestamp_converter.dart';

part 'photo.freezed.dart';
part 'photo.g.dart';

@freezed
class RemotePhoto with _$RemotePhoto {
  const factory RemotePhoto({
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

    /// FirebaseStorageに保存された写真の周辺店舗のIdリスト
    @Default(<String>[]) List<String> areaStoreIds,

    /// FirebaseStorageに保存された写真のURL
    @Default('') String url,

    /// ローカルストレージに保存された画像のパス
    @Default('') String localImagePath,

    /// Firestoreに保存されたドキュメントのID
    @Default('') String firestoreDocumentId,

    /// geminiで推論した写真のカテゴリ
    /// ここをstringではなくてenumに変換して格納しておくと、
    /// Flutter上では型安全に扱えて想定外の実行時エラーが防げるため修正したい
    @Default('') String category,

    /// FirebaseStorageのドキュメントID
    @Default('') String userId,

    /// 写真の撮影日時
    @timestampConverter
    @Default(UnionTimestamp.serverTimestamp())
    UnionTimestamp shotAt,
    @Default('') String storeId,
  }) = _RemotePhoto;

  const RemotePhoto._();

  factory RemotePhoto.fromJson(Map<String, dynamic> json) =>
      _$RemotePhotoFromJson(json);
}
