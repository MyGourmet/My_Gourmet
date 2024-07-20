import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../auth/auth_repository.dart';
import 'photo.dart';
import 'photo_repository.dart';

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

  /// 画像分類ステータスの更新用メソッド
  Future<void> upsertClassifyPhotosStatus({
    required String userId,
  }) async {
    await _authRepository.upsertClassifyPhotosStatus(userId);
  }

  // todo delete
  /// 写真ダウンロード用メソッド
  Future<List<Photo>> downloadPhotos({
    required String userId,
  }) async {
    return _photoRepository.downloadPhotos(userId: userId);
  }

  // todo 写真ダウンロード用メソッド作成

  Future<String> getStoreNameFromStoreId(String storeId) async {
    return await _photoRepository.fetchStoreNameFromStoreId(storeId);
  }

  Future<Photo?> getPhotoById({
    required String userId,
    required String photoId,
  }) async {
    return await _photoRepository.getPhotoById(
      userId: userId,
      photoId: photoId,
    );
  }
}
