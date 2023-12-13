import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:my_gourmet/features/auth/auth_repository.dart';

import 'authed_user.dart';

// TODO(masaki): オンボーディングの設計次第でuserIdの取得方法を検討
// i) 画面遷移時のみuserIdの有無を把握するので良い場合
// ページに対してコンストラクタ経由でnull許容せずに渡すのが良さそう
// ii) 画面遷移後にサインインする可能性がある場合
// ログインしていることをcontroller側で担保する等して毎度のnullチェックを不要にしたい

/// [FirebaseAuth]のインスタンスを提供するProvider
final _authProvider =
    Provider<FirebaseAuth>((ref) => ref.watch(authRepositoryProvider).auth);

/// [FirebaseAuth]の[User]を管理するProvider
///
/// 認証状態が変更(ログイン/ログアウト)される度に更新される
final _userProvider =
    StreamProvider<User?>((ref) => ref.watch(_authProvider).userChanges());

/// userIdを管理するProvider
///
/// [_userProvider]をwatchしているため、認証状態の変更を検知する
final userIdProvider = Provider<String?>((ref) {
  ref.watch(_userProvider);
  return ref.watch(_authProvider).currentUser?.uid;
});

/// [AuthedUser]を購読するProvider
final authedUserStreamProvider = StreamProvider.autoDispose<AuthedUser>(
  (ref) => ref.watch(authRepositoryProvider).subscribeAuthedUser(),
);