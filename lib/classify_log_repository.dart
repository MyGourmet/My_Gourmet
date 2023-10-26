import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:my_gourmet/classify_log.dart';

// TODO(masaki): 命名やディレクトリ構成を改修

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
