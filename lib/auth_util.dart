import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:my_gourmet/classify_log.dart';

final authUtilProvider = Provider((ref) => AuthUtil._());

// TODO(masaki): 命名やディレクトリ構成を改修
class AuthUtil {
  AuthUtil._();

  final FirebaseAuth auth = FirebaseAuth.instance;

  Future<({String accessToken})> signInWithGoogle() async {
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
    final accessToken = googleAuth.accessToken;

    await auth.signInWithCredential(credential);

    final user = auth.currentUser;
    final userId = user?.uid;

    if (accessToken == null || userId == null) {
      throw Exception('サインインに失敗しました.');
    }

    return (accessToken: accessToken);
  }

  Future<String?> getCurrentUserId() async {
    final user = auth.currentUser;
    return user?.uid;
  }

  // TODO(masaki): StreamBuilder周り改修後に削除
  final classifylogsReference = FirebaseFirestore.instance
      .collection('classifylogs')
      .withConverter<ClassifyLog>(
    // <> ここに変換したい型名をいれます。今回は ClassifyLog です。
    fromFirestore: ((snapshot, _) {
      // 第二引数は使わないのでその場合は _ で不使用であることを分かりやすくしています。
      return ClassifyLog.fromFirestore(
          snapshot); // 先ほど定期着した fromFirestore がここで活躍します。
    }),
    toFirestore: ((value, _) {
      return value.toMap(); // 先ほど適宜した toMap がここで活躍します。
    }),
  );
}
