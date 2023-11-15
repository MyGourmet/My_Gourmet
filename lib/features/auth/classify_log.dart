import 'package:cloud_firestore/cloud_firestore.dart';

// TODO(masaki): AuthedUserに差し替え
class ClassifyLog {
  ClassifyLog({
    required this.createdAt,
    required this.updatedAt,
    required this.userId,
    required this.state,
    required this.reference,
  });

  factory ClassifyLog.fromFirestore(
      DocumentSnapshot<Map<String, dynamic>> snapshot) {
    final map = snapshot.data()!; // data() の中には Map 型のデータが入っています。
    // data()! この ! 記号は nullable な型を non-nullable として扱うよ！ という意味です。
    // data の中身はかならず入っているだろうという仮説のもと ! をつけています。
    // map データが得られているのでここからはいつもと同じです。
    return ClassifyLog(
      createdAt: map['createdAt'],
      updatedAt: map['updatedAt'],
      userId: map['userId'],
      state: map['state'],
      reference:
          snapshot.reference, // 注意。reference は map ではなく snapshot に入っています。
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'createdAt': createdAt,
      'updatedAt': updatedAt,
      'userId': userId,
      'state': state,
      // 'reference': reference, reference は field に含めなくてよい
      // field に含めなくても DocumentSnapshot に reference が存在するため
    };
  }

  /// 作成日時
  final Timestamp createdAt;

  /// 更新日時
  final Timestamp updatedAt;

  /// 投稿者のユーザーID
  final String userId;

  /// 投稿者のアイコン画像URL
  final String state;

  /// Firestoreのどこにデータが存在するかを表すpath情報
  final DocumentReference reference;
}

final classifyLogsReference = FirebaseFirestore.instance
    .collection('ClassifyLogs')
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
