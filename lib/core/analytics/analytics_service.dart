import 'dart:developer';

import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../core/flavor.dart';
import '../../features/auth/auth_repository.dart';

/// [AnalyticsService]を提供する[Provider]
final analyticsServiceProvider = Provider((ref) {
  // パラメータに付与するユーザー情報の取得
  final authUser = ref.watch(authRepositoryProvider).auth;

  return AnalyticsService(
    // 全てのユーザーから取得する初期値
    parameters: {
      'env': flavor.name,
      'u_id': authUser.currentUser?.uid ?? '',
      'display_name': authUser.currentUser?.displayName ?? '',
    },
  );
});

/// Analyticsに関する操作を担当するクラス
///
/// 参考)
/// https://www.kamo-it.org/blog/flutter-analytics/
class AnalyticsService {
  AnalyticsService({required Map<String, Object?> parameters})
      : _parameters = parameters;

  /// [FirebaseAnalytics]のインスタンス
  static final FirebaseAnalytics _analytics = FirebaseAnalytics.instance;

  /// スネークケースのパラメータ
  final Map<String, Object?> _parameters;

  /// どの画面を開いているか、Analyticsにログを送信するメソッド
  ///
  /// logEvent name : screen_view_event
  /// setCurrentScreenにはparameterを設定できないので、同時にlogEventも発火している。
  /// 参考)
  /// https://www.kamo-it.org/blog/flutter-analytics/
  void sendScreenView(String path) {
    _parameters
      // event_nameが残っていたら余計な情報なので省く
      ..remove('event_name')
      ..addAll({'screen_name': path});
    // パラメータの内容の確認
    log('Analyticsのパラメータ : $_parameters');

    _analytics
      ..logEvent(name: 'screen_view_event', parameters: _parameters)
      ..logScreenView(screenName: path);
  }

  /// どのボタンを押したか、Analyticsに送信するメソッド
  ///
  /// logEvent name : event_name
  Future<void> sendEvent({
    required String name,
    Map<String, Object?> addParameters = const {},
  }) async {
    // // _parametersに追加パラメータを結合
    _parameters
      ..addAll({'event_name': name})
      ..addAll(addParameters);

    await _analytics.logEvent(name: name, parameters: _parameters);
  }

  /// Analyticsに一律追加したいパラメータを設定するメソッド
  void setAddParameters({
    required Map<String, Object?> addParameters,
  }) {
    _parameters.addAll(addParameters);
    // パラメータの内容の確認
    log('追加後のAnalyticsのパラメータの状態 : $_parameters');
  }
}
