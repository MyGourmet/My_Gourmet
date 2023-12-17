import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:my_gourmet/features/auth/authed_user.dart';

/// [AuthedUser]用コレクションのためのレファレンス
///
/// [AuthedUser]ドキュメントの操作にはこのレファレンスを経由すること。
/// [fromFirestore]ではドキュメントidを追加し、[toFirestore]ではドキュメントidを削除する。
/// 常に[toFirestore]を経由するためにドキュメント更新時には[DocumentReference.update]ではなく[DocumentReference.set]を用いる。
final authedUsersRef =
    FirebaseFirestore.instance.collection('users').withConverter<AuthedUser>(
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
    final AuthedUser authedUser;
    if (userDocSnapshot.exists) {
      authedUser = userDocSnapshot
          .data()!
          .copyWith(classifyPhotosStatus: ClassifyPhotosStatus.processing);
    } else {
      authedUser = const AuthedUser(
          classifyPhotosStatus: ClassifyPhotosStatus.processing);
    }
    // ドキュメントが存在しない場合は新規作成、存在する場合は中身を全て置き換え
    await userDoc.set(authedUser);
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
