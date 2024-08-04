import 'dart:convert';
import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;

import '../../core/flavor.dart';
import '../../logger.dart';
import 'store.dart';

/// [Store]用コレクションのためのレファレンス
///
/// [Store]ドキュメントの操作にはこのレファレンスを経由すること。
/// fromFirestoreではドキュメントidを追加し、toFirestoreではドキュメントidを削除する。
/// 常にtoFirestoreを経由するために、ドキュメント更新時には
/// [DocumentReference.update]ではなく[DocumentReference.set]を用いる。
CollectionReference<Store> storesRef({required String userId}) {
  return FirebaseFirestore.instance.collection('stores').withConverter<Store>(
    fromFirestore: (snapshot, _) {
      final data = snapshot.data()!;
      return Store.fromJson(<String, dynamic>{
        ...data,
        'id': snapshot.id,
      });
    },
    toFirestore: (store, _) {
      final json = store.toJson()..remove('id');
      return json;
    },
  );
}

final storeRepositoryProvider = Provider((ref) => StoreRepository._());

class StoreRepository {
  StoreRepository._();

  // OAuth 2.0 REST APIエンドポイント
  final String _apiUrl =
      flavor.isProd ? dotenv.env['PROD_API_URL']! : dotenv.env['DEV_API_URL']!;

  Future<Store?> getStoreById({
    required String userId,
    required String storeId,
  }) async {
    try {
      final docSnapshot = await storesRef(userId: userId).doc(storeId).get();
      if (docSnapshot.exists) {
        return docSnapshot.data();
      } else {
        return null;
      }
    } on Exception catch (e) {
      logger.e('Error fetching store: $e');
      return null;
    }
  }
}
