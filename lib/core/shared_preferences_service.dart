import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// [SharedPreferences]のキーを管理するenum
enum SharedPreferencesKey {
  /// オンボーディングが完了したかどうか
  isOnboardingCompleted,
}

/// [SharedPreferencesService]用プロバイダー
///
/// アプリ起動時 or テスト時に、初期化のために[ProviderContainer]経由で呼び出してインスタンスを生成しておく。
final sharedPreferencesServiceProvider = Provider<SharedPreferencesService>(
  (ref) => SharedPreferencesService._(),
);

/// [SharedPreferences]を操作するクラス
class SharedPreferencesService {
  SharedPreferencesService._();

  late final SharedPreferences _sharedPreferences;

  /// 初期化処理
  Future<void> init() async {
    _sharedPreferences = await SharedPreferences.getInstance();
  }

  /// bool用書き込み処理
  Future<bool> setBool({
    required SharedPreferencesKey key,
    required bool value,
  }) async {
    return _sharedPreferences.setBool(key.name, value);
  }

  /// bool用読み込み処理
  bool getBool({
    required SharedPreferencesKey key,
  }) {
    return _sharedPreferences.getBool(key.name) ?? false;
  }
}
