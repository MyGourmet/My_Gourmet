import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_sign_in/google_sign_in.dart';

final authUtilProvider = Provider((ref) => AuthUtil._());

// TODO(masaki): 命名やディレクトリ構成を改修
class AuthUtil {
  AuthUtil._();

  /// [FirebaseAuth]のインスタンス
  FirebaseAuth get auth => _auth;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<({String accessToken, String userId})> signInWithGoogle() async {
    final googleUser = await GoogleSignIn(scopes: [
      'profile',
      'email',
      'https://www.googleapis.com/auth/photoslibrary'
    ]).signIn();

    if (googleUser == null) {
      throw Exception('サインインに失敗しました.');
    }

    final googleAuth = await googleUser.authentication;
    final credential = GoogleAuthProvider.credential(
      accessToken: googleAuth.accessToken,
      idToken: googleAuth.idToken,
    );

    await _auth.signInWithCredential(credential);

    final accessToken = googleAuth.accessToken;
    final userId = _auth.currentUser?.uid;
    if (accessToken == null || userId == null) {
      throw Exception('サインインに失敗しました.');
    }
    return (accessToken: accessToken, userId: userId);
  }

  Future<String?> getCurrentUserId() async {
    final user = _auth.currentUser;
    return user?.uid;
  }
}
