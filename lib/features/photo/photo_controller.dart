import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:my_gourmet/features/auth/auth_repository.dart';
import 'package:my_gourmet/features/photo/photo.dart';
import 'package:my_gourmet/features/photo/photo_repository.dart';

final photoControllerProvider = Provider<PhotoController>(PhotoController._);

/// 写真に関連した外部通信の操作を担当するコントローラー
///
/// 写真関連の外部通信を行う際にはこのコントローラーを[photoControllerProvider]経由で操作する。
/// 別クラスを参照する場合は、refによりgetter経由でインスタンス化して用いる。
/// refを渡さずコンストラクタから依存性を注入するようにすると
/// クラス内で_ref.invalidateメソッド等を用いたriverpodらしい状態管理が出来なくなるため、依存関係はgetterで表現しておく。
class PhotoController {
  PhotoController._(this._ref);

  final Ref _ref;

  AuthRepository get _authRepository => _ref.read(authRepositoryProvider);

  PhotoRepository get _photoRepository => _ref.read(photoRepositoryProvider);

  /// 写真アップロード用メソッド
  ///
  /// サインインをした上でfirestore上で状態管理し、写真アップロード用のCFを起動する。
  Future<void> uploadPhotos({required String? userId}) async {
    // TODO(masaki): ログイン後はfunction-5とは別のaccessToken不要な更新処理を実行
    // if (userId != null) {
    //   // 更新処理
    //   return;
    // }

    // MEMO(masaki): 未ログインの初回はオンボーディング用の実装に切り替える

    // TODO(masaki): ここ用にserviceクラス作るか検討
    final result = await _authRepository.signInWithGoogle();
    await _authRepository.upsertUploadingStatus(result.userId);
    await _photoRepository.callFirebaseFunction(
        result.accessToken, result.userId);
  }

  /// 写真ダウンロード用メソッド
  Future<List<Photo>> downloadPhotos(
      {required String category, required String? userId}) async {
    if (userId == null) {
      return [];
    }
    return _photoRepository.downloadPhotos(category: category, userId: userId);
  }
}
