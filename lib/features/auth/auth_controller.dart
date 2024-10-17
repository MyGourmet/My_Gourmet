import 'package:firebase_auth/firebase_auth.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import 'auth_repository.dart';
import 'authed_user.dart';

/// [FirebaseAuth]のインスタンスを提供するProvider
final _authProvider =
    Provider<FirebaseAuth>((ref) => ref.watch(authRepositoryProvider).auth);

/// [FirebaseAuth]の[User]を管理するProvider
///
/// 認証状態が変更(サインイン/サインアウト)される度に更新される
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

final authControllerProvider = Provider<AuthController>(AuthController.new);

/// [AuthRepository]を経由して外部通信の操作を担当するコントローラー
class AuthController {
  AuthController(this._ref);

  final Ref _ref;

  AuthRepository get _authRepository => _ref.read(authRepositoryProvider);

  /// ユーザーアカウント削除用メソッド
  Future<void> deleteUserAccount() async {
    await _authRepository.deleteUserAccount();
  }

  /// Googleサインイン用メソッド
  Future<({String accessToken, String userId})> signInWithGoogle() async {
    return _authRepository.signInWithGoogle();
  }

  /// Appleサインイン用メソッド
  Future<({String accessToken, String userId})> signInWithApple() async {
    return _authRepository.signInWithApple();
  }
}
