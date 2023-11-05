import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:my_gourmet/auth_controller.dart';
import 'package:my_gourmet/auth_util.dart';
import 'package:my_gourmet/function_util.dart';
import 'package:my_gourmet/home_page.dart';

import 'classify_log_repository.dart';

final homepageControllerProvider =
    Provider<HomePageController>(HomePageController._);

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
  String? get _userId => _ref.read(userIdProvider);

  /// 画像アップロード用メソッド
  ///
  /// サインインをした上でfirestore上で状態管理し、画像アップロード用のCFを起動する。
  Future<void> uploadImages() async {
    // // TODO(masaki): 未ログイン(_userIdがnull) or オンボーディングの時のみ画像をアップロードするようにする
    // オンボーディング時以外はfunction-5とは別のaccessTokenな更新処理を実行
    final result = await _authUtil.signInWithGoogle();
    await updateOrCreateLog(_userId!);

    await _functionUtil.callFirebaseFunction(result.accessToken, _userId!);
  }

  /// 画像ダウンロード用メソッド
  Future<List<String>> downloadImages(String category) async {
    if (_userId == null) {
      return [];
    }
    return _functionUtil.downloadImages(category: category, userId: _userId!);
  }
}
