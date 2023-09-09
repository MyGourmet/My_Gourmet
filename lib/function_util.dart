import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:my_gourmet/classify_log.dart';
import 'classify_login_main.dart';
import 'firebase_options.dart';
import 'package:logger/logger.dart';

class FunctionUtil {
  FunctionUtil._();
  static final instance = FunctionUtil._();

  Future<void> callFirebaseFunction(String accessToken) async {
    try {
      final result = await call(
        functionName: 'function-2',
        parameters: {
          'name': accessToken,
        },
      );
      // final Map<String, dynamic> response =
      //     jsonDecode(result.data) ?? {'message': 'Unknown response'};
      // final String message = response["message"];

      // setState(() {
      //   _functionResult = message;
      // });
    } catch (error) {
      print(error);
      // setState(() {
      //   _functionResult = 'Failed to call function: $error';
      // });
    }
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
