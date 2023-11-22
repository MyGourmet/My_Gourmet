// TODO(masaki): use freezed
/// 認証済みユーザーの情報を表すクラス
class AuthedUser extends Object {
  final String id;
  final DateTime createdAt;
  final DateTime updatedAt;
  final UploadingStatus uploadingStatus;

  AuthedUser({
    required this.id,
    required this.createdAt,
    required this.updatedAt,
    required this.uploadingStatus,
  });
}

/// 画像アップロードの状態を表すenum
enum UploadingStatus {
  /// 処理中
  uploading,

  /// 完了
  completed,

  /// 失敗
  // TODO(masaki): エラーハンドリングを別途検討
  failed,
}
