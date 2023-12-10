import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

import '../../timestamp_converter.dart';

part 'authed_user.freezed.dart';
part 'authed_user.g.dart';

/// 認証済みユーザーの情報を表すクラス
@freezed
class AuthedUser with _$AuthedUser {
  // TODO(masaki): 初期値を入れるか検討
  // TODO(masaki): 初期値入れてもnullableでしか扱えないようであったら、書き込みと読み込み用(Flutter側で基本用いるもの）を分けることを検討
  const factory AuthedUser({
    /// firestore上のドキュメントID
    @Default('') String id,

    /// 作成日時
    @timestampConverter
    @Default(UnionTimestamp.serverTimestamp())
    UnionTimestamp createdAt,

    /// 更新日時
    @serverTimeTimestampConverter
    @Default(UnionTimestamp.serverTimestamp())
    UnionTimestamp updatedAt,

    /// 写真アップロードの状態
    @Default(UploadingStatus.completed) UploadingStatus uploadingStatus,
  }) = _AuthedUser;

  const AuthedUser._();

  // TODO(masaki): 以下必要か検討
  /// gmailアドレス(今後直接ユーザーにコンタクトを取るために保存しておく）
  // final String email;
  /// gmailアカウントに登録された名前(ユーザー分析用 or 今後ユーザー名を用いる際の初期値として用いる）
  // final String registeredName;

  factory AuthedUser.fromJson(Map<String, dynamic> json) =>
      _$AuthedUserFromJson(json);

  factory AuthedUser.fromDocumentSnapshot(DocumentSnapshot ds) {
    final data = ds.data()! as Map<String, dynamic>;
    // TODO(masaki): idが取得できているか動作確認
    // TODO(masaki): enum用converter作成
    data['uploadingStatus'] =
        UploadingStatus.fromString(data['uploadingStatus'].toString());
    return AuthedUser.fromJson(<String, dynamic>{
      ...data,
      'id': ds.id,
    });
  }
}

/// 写真アップロードの状態を表すenum
enum UploadingStatus {
  /// 処理中
  uploading,

  /// 完了
  completed,

  /// 失敗
  // TODO(masaki): エラーハンドリングを別途検討
  failed;

  static fromString(String value) {
    switch (value) {
      case 'uploading':
        return UploadingStatus.uploading;
      case 'completed':
        return UploadingStatus.completed;
      case 'failed':
        return UploadingStatus.failed;
      default:
        return UploadingStatus.completed;
    }
  }
}

/// [AuthedUser]用コレクションのためのレファレンス
///
/// [AuthedUser]ドキュメントの操作にはこのレファレンスを経由すること。
/// [fromFirestore]ではドキュメントidを追加し、[toFirestore]ではドキュメントidを削除する。
final authedUsersRef =
    FirebaseFirestore.instance.collection('users').withConverter<AuthedUser>(
  fromFirestore: ((ds, _) {
    return AuthedUser.fromDocumentSnapshot(ds);
  }),
  toFirestore: (authedUser, _) {
    final json = authedUser.toJson();
    json['uploadingStatus'] = authedUser.uploadingStatus.name;
    json.remove('id');
    return json;
  },
);
