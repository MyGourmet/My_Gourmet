import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:my_gourmet/features/auth/auth_util.dart';
import 'package:my_gourmet/features/image/function_util.dart';
import 'package:my_gourmet/view/home_page.dart';

import 'auth/classify_log_repository.dart';

final homepageControllerProvider =
    Provider<HomePageController>(HomePageController._);

// TODO(masaki): feature単位のcontrollerにする
/// [HomePage]における外部通信の操作を担当するコントローラー
///
/// [HomePage]から外部通信を行う際にはこのコントローラーを[homepageControllerProvider]経由で操作する。
/// 別クラスを参照する場合は、refによりgetter経由でインスタンス化して用いる。
/// refを渡さずコンストラクタから依存性を注入するようにすると
/// クラス内で_ref.invalidateメソッド等を用いたriverpodらしい状態管理が出来なくなるため、依存関係はgetterで表現しておく。
class HomePageController {
  HomePageController._(this._ref);

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