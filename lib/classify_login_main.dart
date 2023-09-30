import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:my_gourmet/auth_util.dart';
import 'package:my_gourmet/classify_log.dart';
import 'package:my_gourmet/function_util.dart';
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
  bool isLoading = false; // 処理中を表すフグを追加

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
            onPressed: () async {
              setState(() {
                isLoading = true; // ボタンが押されたら、isLoadingをtrueに設定
              });
              await onPressed();
            },
          ),
          isLoading // 処理中なら「処理中」と表示、そうでなければStreamBuilderを表示
              ? Text('処理中')
              : StreamBuilder<QuerySnapshot<ClassifyLog>>(
                  stream: AuthUtil.instance.classifylogsReference
                      .where('userId', isEqualTo: userId)
                      .snapshots(),
                  builder: (context, snapshot) {
                    final docs = snapshot.data?.docs ?? [];
                    if (docs.isNotEmpty) {
                      final classifyLog = docs.first.data();
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

  Future<void> onPressed() async {
    final result = await AuthUtil.instance.signInWithGoogle();
    setState(() {
      userId = result[1]!;
      isLoading = false; // 非同期処理が完了したら、isLoadingをfalseに設定
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('サインインが完了しました。')),
    );
    final accessToken = result[0]!;
    FunctionUtil.instance.callFirebaseFunction(accessToken);
  }
}
