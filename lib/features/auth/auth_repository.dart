import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';

import '../../core/logger.dart';
import 'authed_user.dart';
import 'sign_in_page.dart';

/// [AuthedUser]用コレクションのためのレファレンス
///
/// [AuthedUser]ドキュメントの操作にはこのレファレンスを経由すること。
/// fromFirestoreではドキュメントidを追加し、toFirestoreではドキュメントidを削除する。
/// 常にtoFirestoreを経由するために、ドキュメント更新時には
/// [DocumentReference.update]ではなく[DocumentReference.set]を用いる。
final authedUsersRef =
    FirebaseFirestore.instance.collection('users').withConverter<AuthedUser>(
  fromFirestore: (ds, _) {
    final data = ds.data()!;
    return AuthedUser.fromJson(<String, dynamic>{
      ...data,
      'id': ds.id,
    });
  },
  toFirestore: (authedUser, _) {
    final json = authedUser.toJson()..remove('id');
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

  bool isSignedIn() {
    return _auth.currentUser != null;
  }

  // Googleサインインのメソッド
  Future<({String accessToken, String userId})> signInWithGoogle() async {
    final googleUser = await GoogleSignIn(
      scopes: [
        'profile',
        'email',
      ],
    ).signIn();

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

  // Appleサインインのメソッド
  Future<({String accessToken, String userId})> signInWithApple() async {
    try {
      // Appleサインインの認証
      final appleCredential = await SignInWithApple.getAppleIDCredential(
        scopes: [
          AppleIDAuthorizationScopes.email,
          AppleIDAuthorizationScopes.fullName,
        ],
      );

      final oauthCredential = OAuthProvider('apple.com').credential(
        idToken: appleCredential.identityToken,
        accessToken: appleCredential.authorizationCode,
      );

      // Firebase Authにサインイン
      await _auth.signInWithCredential(oauthCredential);

      final userId = _auth.currentUser?.uid;
      final accessToken = appleCredential.authorizationCode;

      if (userId == null) {
        throw Exception('Appleサインインに失敗しました。');
      }

      return (accessToken: accessToken, userId: userId);
    } on SignInWithAppleAuthorizationException catch (e) {
      logger.e('Apple Sign-In failed: ${e.message}');
      throw Exception('Appleサインインに失敗しました: ${e.code}');
    } on Exception catch (e) {
      logger.e('Apple Sign-In error: $e');
      rethrow;
    }
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
          .copyWith(classifyPhotosStatus: ClassifyPhotosStatus.readyForUse);
    } else {
      authedUser = const AuthedUser();
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

  /// ユーザーアカウントを削除する
  Future<void> deleteUserAccount(
    BuildContext context,
  ) async {
    try {
      final userId = _auth.currentUser?.uid;
      if (userId == null) {
        // サインインページに遷移
        GoRouter.of(context).go(SignInPage.routePath);
      }
      await call(
        functionName: 'deleteAccount',
        parameters: {
          'userId': userId,
        },
      );
      await _auth.currentUser?.delete();
    } on Exception catch (error) {
      logger.e(error.toString());
    }
  }

  /// CloudFunctionsのCallable関数を呼び出す
  Future<HttpsCallableResult<dynamic>> call({
    required String functionName,
    String? region,
    Map<String, dynamic>? parameters,
  }) async {
    try {
      final functions = FirebaseFunctions.instanceFor(
        app: Firebase.app(),
        region: region ?? 'asia-northeast1',
      );
      final callable = functions.httpsCallable(functionName);
      return await callable.call(parameters);
    } on Exception {
      rethrow;
    }
  }
}
