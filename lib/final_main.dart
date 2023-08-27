import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'package:logger/logger.dart';
import 'dart:convert';

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
  final GoogleSignIn _googleSignIn = GoogleSignIn(scopes: [
    'https://www.googleapis.com/auth/photoslibrary',
    'profile',
    'email'
  ]);

  // String _functionResponse = ""; // これを追加
  String _functionResult = '';

  Future<void> signInWithGoogle() async {
    try {
      final googleUser = await _googleSignIn.signIn();
      print('_googleSignIn: ${googleUser}');
      if (googleUser != null) {
        final googleAuth = await googleUser.authentication;
        print(
            'Successfully signed in with Google. Access token is: ${googleAuth.accessToken}');

        // Calling Firebase Cloud Function with ID Token
        await callFirebaseFunction(
            googleAuth.accessToken ?? 'defaultTokenValue');
      }
    } catch (error) {
      print('Error occurred during Google Sign-In: $error');
    }
  }

  Future<void> callFirebaseFunction(String accessToken) async {
    try {
      final result = await call(
        functionName: 'function-1',
        parameters: {
          'name': accessToken,
        },
      );
      final Map<String, dynamic> response =
          jsonDecode(result.data) ?? {'message': 'Unknown response'};  // ここを修正
      final String message = response["message"] ?? 'Unknown message';

      setState(() {
        _functionResult = message;
      });
    } catch (error) {
      print(error);
      setState(() {
        _functionResult = 'Failed to call function: $error';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('GoogleSignIn with Google Photos Access'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              child: Text('Sign In with Google'),
              onPressed: signInWithGoogle,
            ),
            SizedBox(height: 20), // Some spacing between the button and text
            Text(_functionResult), // これを追加
          ],
        ),
      ),
    );
  }

  /// CloudFunctionsを呼び出す
  Future<HttpsCallableResult> call({
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
      print(callable);
      return await callable.call(parameters);
    } catch (e) {
      logger.d(e);
      rethrow;
    }
  }
}
