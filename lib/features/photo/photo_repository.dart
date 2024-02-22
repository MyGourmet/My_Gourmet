import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;

import '../../core/flavor.dart';
import 'photo.dart';

/// [Photo]用コレクションのためのレファレンス
///
/// [Photo]ドキュメントの操作にはこのレファレンスを経由すること。
/// fromFirestoreではドキュメントidを追加し、toFirestoreではドキュメントidを削除する。
/// 常にtoFirestoreを経由するために、ドキュメント更新時には
/// [DocumentReference.update]ではなく[DocumentReference.set]を用いる。
CollectionReference<Photo> photosRef({required String userId}) {
  return FirebaseFirestore.instance
      .collection('users')
      .doc(userId)
      .collection('photos')
      .withConverter<Photo>(
    fromFirestore: (snapshot, _) {
      final data = snapshot.data()!;
      return Photo.fromJson(<String, dynamic>{
        ...data,
        'id': snapshot.id,
      });
    },
    toFirestore: (photo, _) {
      final json = photo.toJson()..remove('id');
      return json;
    },
  );
}

final photoRepositoryProvider = Provider((ref) => PhotoRepository._());

class PhotoRepository {
  PhotoRepository._();

  // OAuth 2.0 REST APIエンドポイント
  final String _apiUrl =
      flavor.isProd ? dotenv.env['PROD_API_URL']! : dotenv.env['DEV_API_URL']!;

  Future<void> callClassifyPhotos(String accessToken, String userId) async {
    try {
      final response = await http.post(
        Uri.parse('$_apiUrl/updateUserStatus'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $accessToken',
        },
        body: jsonEncode({
          'userId': userId,
        }),
      );

      if (response.statusCode == 200) {
        // 成功した場合の処理
        debugPrint('API call successful: ${response.body}');
      } else {
        // エラーが返された場合の処理
        debugPrint('API call failed: ${response.body}');
      }
    } on Exception catch (error) {
      debugPrint(error.toString());
    }
  }

  /// CF上のclassifyPhotos関数を呼び出す
  Future<void> callDeleteUserAccount(String userId) async {
    try {
      await call(
        functionName: 'deleteAccount',
        parameters: {
          'userId': userId,
        },
      );
    } on Exception catch (error) {
      debugPrint(error.toString());
    }
  }

  // TODO(masaki): firestoreへデータ作成後に動作確認 & 全件取得ではない取得方法検討
  Future<List<Photo>> downloadPhotos({
    required String category,
    required String userId,
  }) async {
    try {
      // Firestoreのクエリを実行して、ドキュメントIDで降順にソート
      final QuerySnapshot photosSnap = await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .collection('photos')
          // ドキュメントIDで降順にソート
          .orderBy(FieldPath.documentId, descending: true)
          .get();

      // ドキュメントのデータをPhotoオブジェクトに変換
      return photosSnap.docs
          .map((doc) {
            final data = doc.data();
            if (data != null) {
              // nullチェックを追加
              return Photo.fromJson(data as Map<String, dynamic>); // キャストを修正
            } else {
              return null;
            }
          })
          .where((photo) => photo != null)
          .cast<Photo>()
          .toList();
    } on Exception catch (e) {
      debugPrint('An error occurred: $e');
      return [];
    }
  }

  /// CloudFunctionsを呼び出す
  Future<HttpsCallableResult<dynamic>> call({
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
    } on Exception {
      rethrow;
    }
  }
}
