import 'package:cloud_functions/cloud_functions.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:my_gourmet/features/photo/photo.dart';

final photoRepositoryProvider = Provider((ref) => PhotoRepository._());

class PhotoRepository {
  PhotoRepository._();

  /// CF上のclassifyPhotos関数を呼び出す
  Future<void> callClassifyPhotos(String accessToken, String userId) async {
    try {
      // TODO(masaki): 関数実装後にfunctionタイプなど諸々調整して呼び出す
      // await call(
      //   functionName: 'classifyPhotos',
      //   parameters: {
      //     'name': accessToken,
      //     'userId': userId,
      //   },
      // );
    } catch (error) {
      debugPrint(error.toString());
    }
  }

  // TODO(masaki): firestoreへデータ作成後に動作確認
  Future<List<Photo>> downloadPhotos(
      {required String category, required String userId}) async {
    try {
      final photosSnap = await photosRef(userId: userId).get();
      return photosSnap.docs.map((photo) {
        return Photo(
          id: photo.id,
          createdAt: photo.data().createdAt,
          updatedAt: photo.data().updatedAt,
          url: photo.data().url,
          userId: photo.data().userId,
          otherUrls: photo.data().otherUrls,
        );
      }).toList();
    } catch (e) {
      debugPrint("An error occurred: $e");
      return [];
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
      return await callable.call(parameters);
    } catch (e) {
      rethrow;
    }
  }
}