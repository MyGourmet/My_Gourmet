import 'package:cloud_functions/cloud_functions.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final functionUtilProvider = Provider((ref) => FunctionUtil._());

// TODO(masaki): 命名やディレクトリ構成を改修。画像を関心事にしたrepositoryへ変更
class FunctionUtil {
  FunctionUtil._();

  Future<void> callFirebaseFunction(String accessToken, String userId) async {
    try {
      await call(
        functionName: 'function-5',
        parameters: {
          'name': accessToken,
          'userId': userId,
        },
      );
    } catch (error) {
      debugPrint(error.toString());
      // setState(() {
      //   _functionResult = 'Failed to call function: $error';
      // });
    }
  }

  Future<List<String>> downloadImages(
      {required String category, required String userId}) async {
    try {
      final storage = FirebaseStorage.instance;
      ListResult result = await storage
          .ref()
          .child(
              'photo-jp-my-gourmet-image-classification-2023-08/$userId/$category')
          .list();
      List<String> urls = [];
      // TODO(masaki): 非同期処理最適化
      for (var item in result.items) {
        final url = await item.getDownloadURL();
        urls.add(url);
      }
      return urls;
    } catch (e) {
      debugPrint("An error occurred: $e");
      return [];
    }
  }

  /// CloudFunctionsを呼び出す
  //TODO(masaki): この部分が別の箇所でも必要なようであれば切り出す
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
      return await callable.call(parameters);
    } catch (e) {
      rethrow;
    }
  }
}
