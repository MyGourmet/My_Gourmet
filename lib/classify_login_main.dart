import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:my_gourmet/classify_log.dart';
import 'firebase_options.dart';
import 'package:logger/logger.dart';

final Logger logger = Logger();
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Google SignIn Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: SignInPage(),
    );
  }
}

class SignInPage extends StatefulWidget {
  @override
  _SignInPageState createState() => _SignInPageState();
}

class _SignInPageState extends State<SignInPage> {
  String userId = '';
  Future<void> signInWithGoogle() async {
    final googleUser =
        await GoogleSignIn(scopes: ['profile', 'email']).signIn();
    final googleAuth = await googleUser?.authentication;
    final credential = GoogleAuthProvider.credential(
      accessToken: googleAuth?.accessToken,
      idToken: googleAuth?.idToken,
    );

    await FirebaseAuth.instance.signInWithCredential(credential);

    // 新しいドキュメントを作成して、stateを"処理中"にする
    final user = FirebaseAuth.instance.currentUser!;

    // この部分でインスタンス変数を更新しています。
    setState(() {
      userId = user.uid; // インスタンス変数を更新
    });

    await updateOrCreateLog(userId);

    // サインインが完了したことを表示
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('サインインが完了しました。')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('GoogleSignIn'),
      ),
      body: Column(
        children: [
          ElevatedButton(
            child: const Text('GoogleSignIn'),
            onPressed: signInWithGoogle,
          ),
          StreamBuilder<QuerySnapshot<ClassifyLog>>(
            stream: classifylogsReference
                .where('userId', isEqualTo: userId)
                .snapshots(),
            builder: (context, snapshot) {
              final docs = snapshot.data?.docs ?? [];
              print(snapshot);
              print(docs);
              if (docs.isNotEmpty) {
                final classifyLog = docs.first.data();
                print(classifyLog.state.toString());
                return Text('状態: ${classifyLog.state}');
              } else {
                return Text('状態: 未確認');
              }
            },
          ),
        ],
      ),
    );
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

    // stateを"処理中"にして、更新日時を更新
    final newClassifyLog = ClassifyLog(
        createdAt: createdAtTimestamp,
        updatedAt: Timestamp.now(),
        userId: userId,
        state: '処理中',
        reference: documentReference);

    await documentReference.set(
        newClassifyLog.toMap(), SetOptions(merge: true)); // 部分的な更新
  } else {
    // 既存のドキュメントを使用
    documentReference = existingDoc.docs.first.reference;
    // ここで createdAtTimestamp を設定します。
    createdAtTimestamp = existingDoc.docs.first.data().createdAt;

    // stateを"処理中"に更新
    await documentReference
        .update({'state': '処理中', 'updatedAt': Timestamp.now()});
  }
}
