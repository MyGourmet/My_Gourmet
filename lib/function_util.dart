import 'package:cloud_functions/cloud_functions.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';

class FunctionUtil {
  FunctionUtil._();
  static final instance = FunctionUtil._();

  Future<void> callFirebaseFunction(String accessToken, String userId) async {
    try {
      final result = await call(
        functionName: 'function-4',
        parameters: {
          'name': accessToken,
          'userId': userId,
        },
      );
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
      rethrow;
    }
  }
}
