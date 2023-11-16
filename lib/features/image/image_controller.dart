import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:my_gourmet/features/auth/auth_util.dart';
import 'package:my_gourmet/features/image/function_util.dart';

import '../auth/classify_log_repository.dart';

final imageControllerProvider = Provider<ImageController>(ImageController._);

// TODO(masaki): Image用データモデル作成（Flutter公式のImageとは別名のクラスを用意する）
/// 画像に関連した外部通信の操作を担当するコントローラー
///
/// 画像関連の外部通信を行う際にはこのコントローラーを[imageControllerProvider]経由で操作する。
/// 別クラスを参照する場合は、refによりgetter経由でインスタンス化して用いる。
/// refを渡さずコンストラクタから依存性を注入するようにすると
/// クラス内で_ref.invalidateメソッド等を用いたriverpodらしい状態管理が出来なくなるため、依存関係はgetterで表現しておく。
class ImageController {
  ImageController._(this._ref);

  final Ref _ref;

  AuthUtil get _authUtil => _ref.read(authUtilProvider);

  FunctionUtil get _functionUtil => _ref.read(functionUtilProvider);

  /// 画像アップロード用メソッド
  ///
  /// サインインをした上でfirestore上で状態管理し、画像アップロード用のCFを起動する。
  Future<void> uploadImages({required String? userId}) async {
    // TODO(masaki): ログイン後はfunction-5とは別のaccessToken不要な更新処理を実行
    // if (userId != null) {
    //   // 更新処理
    //   return;
    // }

    // MEMO(masaki): 未ログインの初回はオンボーディング用の実装に切り替える

    final result = await _authUtil.signInWithGoogle();
    await updateOrCreateLog(result.userId);
    await _functionUtil.callFirebaseFunction(result.accessToken, result.userId);
  }

  /// 画像ダウンロード用メソッド
  Future<List<String>> downloadImages(
      {required String category, required String? userId}) async {
    if (userId == null) {
      return [];
    }
    return _functionUtil.downloadImages(category: category, userId: userId);
  }
}
