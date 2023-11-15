import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:my_gourmet/features/auth/auth_util.dart';

// TODO(masaki): 置き場所検討
// data層的なところに置く場合→わざわざauth utilからインスタンスを持ってくる必要ない
// controllerの場合→controllerクラスを一緒にした際のファイル内の可読性を考慮

// TODO(masaki): オンボーディングの設計次第でuserIdの取得方法を検討
// i) 画面遷移時のみuserIdの有無を把握するので良い場合
// ページに対してコンストラクタ経由でnull許容せずに渡すのが良さそう
// ii) 画面遷移後にサインインする可能性がある場合
// ログインしていることをcontroller側で担保する等して毎度のnullチェックを不要にしたい

/// [FirebaseAuth]のインスタンスを提供するProvider
final _authProvider =
    Provider<FirebaseAuth>((ref) => ref.watch(authUtilProvider).auth);

/// [FirebaseAuth]の[User]を管理するProvider
///
/// 認証状態が変更(ログイン/ログアウト)される度に更新される
final _authUserProvider =
    StreamProvider<User?>((ref) => ref.watch(_authProvider).userChanges());

/// userIdを管理するProvider
///
/// [_authUserProvider]をwatchしているため、認証状態の変更を検知する
final userIdProvider = Provider<String?>((ref) {
  ref.watch(_authUserProvider);
  return ref.watch(_authProvider).currentUser?.uid;
});
