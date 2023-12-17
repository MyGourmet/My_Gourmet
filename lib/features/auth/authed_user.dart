import 'package:freezed_annotation/freezed_annotation.dart';

import '../../timestamp_converter.dart';

part 'authed_user.freezed.dart';
part 'authed_user.g.dart';

/// 認証済みユーザーの情報を表すクラス
@freezed
class AuthedUser with _$AuthedUser {
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

    /// 写真分類用APIの実行状態
    @ClassifyPhotosStatusConverter()
    @Default(ClassifyPhotosStatus.readyForUse)
    ClassifyPhotosStatus classifyPhotosStatus,
  }) = _AuthedUser;

  const AuthedUser._();

  // TODO(masaki): 以下必要か検討
  /// gmailアドレス(今後直接ユーザーにコンタクトを取るために保存しておく）
  // final String email;
  /// gmailアカウントに登録された名前(ユーザー分析用 or 今後ユーザー名を用いる際の初期値として用いる）
  // final String registeredName;

  factory AuthedUser.fromJson(Map<String, dynamic> json) =>
      _$AuthedUserFromJson(json);
}

/// 写真分類用APIの実行状態を表すenum
enum ClassifyPhotosStatus {
  /// 処理中
  processing,

  /// 利用の準備が整っている
  readyForUse,

  /// 失敗
  // TODO(masaki): エラーハンドリングを別途検討
  failed;
}

/// [ClassifyPhotosStatus]用JsonConverter
class ClassifyPhotosStatusConverter
    implements JsonConverter<ClassifyPhotosStatus, String> {
  const ClassifyPhotosStatusConverter();

  @override
  ClassifyPhotosStatus fromJson(String value) {
    switch (value) {
      case 'processing':
        return ClassifyPhotosStatus.processing;
      case 'readyForUse':
        return ClassifyPhotosStatus.readyForUse;
      case 'failed':
        return ClassifyPhotosStatus.failed;
      default:
        return ClassifyPhotosStatus.readyForUse;
    }
  }

  @override
  String toJson(ClassifyPhotosStatus object) {
    return object.name;
  }
}
