import 'dart:developer';

import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../core/flavor.dart';
import '../../features/auth/auth_repository.dart';

final analyticsServiceProvider = Provider((ref) {
  // パラメータに付与するユーザー情報の取得
  final authUser = ref.watch(authRepositoryProvider).auth;

  return AnalyticsService(
    // 全てのユーザーから取得する初期値
    // 'type': 'easy' 「かんたん設定」
    // 'env' : 環境（flavor）の値
    // 他ユーザー情報
    parameters: {
      'type': 'easy',
      'env': flavor.name,

      // analyticsで自動で取得されるパラメータがスネークケースだったのでそちらに合わせた。

      ////////下記を改修
      'u_id': authUser.currentUser?.uid ?? '',
      'display_name': authUser.currentUser?.displayName ?? '',
      // 'application_id': authUser?.applicationId ?? '',
      // 'display_name': authUser?.displayName ?? '',
    },
  );
});

class AnalyticsService {
  AnalyticsService({required Map<String, Object?> parameters})
      : _parameters = parameters;
  static final FirebaseAnalytics analytics = FirebaseAnalytics.instance;
  // パラメータ
  final Map<String, Object?> _parameters;

  /// どの画面を開いているか、Analyticsにログを送信するメソッド
  /// setCurrentScreenにはparameterを設定できないので、同時にlogEventも発火している。
  /// logEvent name : screen_view_event
  /// 参考)
  /// https://www.kamo-it.org/blog/flutter-analytics/
  /// parameter例）
  ///　{
  ///　  type: easy,
  ///　  env: local,
  ///　  application_id: c0a5979b-6418-4a97-b783-f9c360220270,
  ///　  display_name: docodoor_abeabe,
  ///　  screen_name: /complete
  ///　}
  ///

  void sendScreenView(String path) {
    _parameters
      // event_nameが残っていたら余計な情報なので省く
      ..remove('event_name')
      ..addAll({'screen_name': path});
    // パラメータの内容の確認
    log('Analyticsのパラメータ : $_parameters');
    // {type: easy, env: local, applicationId: c0a5979b-6418-4a97-b783-f9c360220270, displayName: docodoor_abeabe, screen_name: /complete}
    analytics
      ..logEvent(name: 'screen_view_event', parameters: _parameters)
      ..logScreenView(screenName: path);
  }

  /// どのボタンを押したか、Analyticsに送信するメソッド
  /// logEvent name : button_event
  /// 参考)
  /// https://www.kamo-it.org/blog/flutter-analytics/
  /// parameter例）
  ///　{
  ///　  type: easy,
  ///　  env: local,
  ///　  button_name: next,
  ///　  application_id: c0a5979b-6418-4a97-b783-f9c360220270,
  ///　  display_name: docodoor_abeabe,
  ///　  screen_name: /complete
  ///　}
  ///
  Future<void> sendEvent({
    required String name,
    Map<String, Object?> addParameters = const {},
  }) async {
    // // _parametersに追加パラメータを結合
    _parameters
      ..addAll({'event_name': name})
      ..addAll(addParameters);

    // Google Analyticsにイベントを送信
    await analytics.logEvent(name: name, parameters: _parameters);
  }

  /// Analyticsに一律追加したいパラメータの設定
  /// 例）旧管理画面から画面遷移した場合などに利用
  ///
  void setAddParameters({
    required Map<String, Object?> addParameters,
  }) {
    _parameters.addAll(addParameters);
    // パラメータの内容の確認
    log('追加後のAnalyticsのパラメータの状態 : $_parameters');
  }
}
