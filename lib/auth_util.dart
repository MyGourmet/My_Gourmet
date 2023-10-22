import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:my_gourmet/classify_log.dart';

import 'function_util.dart';

class AuthUtil {
  AuthUtil._();
  static final instance = AuthUtil._();

  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<List<String?>> signInWithGoogle() async {
    final googleUser =
        await GoogleSignIn(scopes: ['profile', 'email']).signIn();
    var userId = "";
    List<String?> result = [];

    if (googleUser != null) {
      final googleAuth = await googleUser.authentication;
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );
      result.add(googleAuth.accessToken);

      await FirebaseAuth.instance.signInWithCredential(credential);

      // 新しいドキュメントを作成して、stateを"isProcessing"にする
      final user = FirebaseAuth.instance.currentUser!;

      // この部分でインスタンス変数を更新しています。
      userId = user.uid; // インスタンス変数を更新
      result.add(userId);

      await updateOrCreateLog(userId);

      await FunctionUtil.instance.callFirebaseFunction(
          googleAuth.accessToken ?? 'defaultTokenValue', userId);
    }

    return result;
  }

  Future<void> updateOrCreateLog(String userId) async {
    // 既存のドキュメントを検索
    final existingDoc =
        await classifylogsReference.where('userId', isEqualTo: userId).get();

    DocumentReference documentReference;
    Timestamp createdAtTimestamp;

    if (existingDoc.docs.isEmpty) {
      // 新しいドキュメントを作成
      documentReference = classifylogsReference.doc();
      createdAtTimestamp = Timestamp.now();

      // stateを"isProcessing"にして、更新日時を更新
      final newClassifyLog = ClassifyLog(
          createdAt: createdAtTimestamp,
          updatedAt: Timestamp.now(),
          userId: userId,
          state: 'isProcessing',
          reference: documentReference);

      await documentReference.set(
          newClassifyLog.toMap(), SetOptions(merge: true)); // 部分的な更新
    } else {
      // 既存のドキュメントを使用
      documentReference = existingDoc.docs.first.reference;
      // ここで createdAtTimestamp を設定します。
      createdAtTimestamp = existingDoc.docs.first.data().createdAt;

      // stateを"isProcessing"に更新
      await documentReference
          .update({'state': 'isProcessing', 'updatedAt': Timestamp.now()});
    }
  }

  Future<String?> getCurrentUserId() async {
    final user = FirebaseAuth.instance.currentUser;
    return user?.uid;
  }

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
