import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:my_gourmet/features/auth/authed_user.dart';

/// [AuthedUser]用コレクションのためのレファレンス
///
/// [AuthedUser]ドキュメントの操作にはこのレファレンスを経由すること。
/// [fromFirestore]ではドキュメントidを追加し、[toFirestore]ではドキュメントidを削除する。
final authedUsersRef =
    FirebaseFirestore.instance.collection('users').withConverter<AuthedUser>(
  // TODO(masaki): idやenumが取得/書き込みできているか動作確認
  fromFirestore: ((ds, _) {
    final data = ds.data()!;
    return AuthedUser.fromJson(<String, dynamic>{
      ...data,
      'id': ds.id,
    });
  }),
  toFirestore: (authedUser, _) {
    final json = authedUser.toJson();
    json.remove('id');
    return json;
  },
);

/// [AuthRepository]用Provider
///
/// [AuthRepository]を参照する際はこのProviderを用いる。
final authRepositoryProvider = Provider((ref) => AuthRepository._());

/// Auth関連の外部通信を担当するクラス
class AuthRepository {
  AuthRepository._();

  /// [FirebaseAuth]のインスタンス
  FirebaseAuth get auth => _auth;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  /// サインイン用メソッド
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

  /// [ClassifyPhotosStatus]を[ClassifyPhotosStatus.processing]に更新するためのメソッド
  ///
  /// 初回サインアップ後で[AuthedUser]ドキュメントが存在していないようであればドキュメントを新規作成した上で更新する。
  Future<void> upsertClassifyPhotosStatus(String userId) async {
    final userDoc = authedUsersRef.doc(userId);
    final userDocSnapshot = await userDoc.get();
    if (userDocSnapshot.exists) {
      final user = userDocSnapshot.data()!;
      await userDoc.update(user
          .copyWith(classifyPhotosStatus: ClassifyPhotosStatus.processing)
          .toJson());
    } else {
      final authedUser = AuthedUser(
          classifyPhotosStatus: ClassifyPhotosStatus.processing, id: userId);

      await userDoc.set(authedUser);
    }
  }

  Stream<AuthedUser> subscribeAuthedUser() {
    return authedUsersRef
        .doc(_auth.currentUser?.uid)
        .snapshots()
        .map((snapshot) {
      final authedUser = snapshot.data();
      if (authedUser == null) {
        throw Exception('ユーザー情報が取得できませんでした。');
      }
      return authedUser;
    });
  }
}
