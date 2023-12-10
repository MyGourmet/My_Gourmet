import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:my_gourmet/features/auth/authed_user.dart';

final authRepositoryProvider = Provider((ref) => AuthRepository._());

class AuthRepository {
  AuthRepository._();

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

  /// [UploadingStatus]を[UploadingStatus.uploading]に更新するためのメソッド
  ///
  /// 初回サインアップ後で[AuthedUser]ドキュメントが存在していないようであればドキュメントを新規作成した上で更新する。
  Future<void> upsertUploadingStatus(String userId) async {
    final userDoc = authedUsersRef.doc(userId);
    final userDocSnapshot = await userDoc.get();
    if (userDocSnapshot.exists) {
      final user = userDocSnapshot.data()!;
      await userDoc.update(user
          .copyWith(
              // updatedAt: FieldValue.serverTimestamp(),
              uploadingStatus: UploadingStatus.uploading)
          .toJson());
    } else {
      final authedUser =
          AuthedUser(uploadingStatus: UploadingStatus.uploading, id: userId);

      await userDoc.set(authedUser);
    }
  }
}
