import 'package:cloud_firestore/cloud_firestore.dart';

// TODO(masaki): AuthedUserと同様に実装
class Photo extends Object {
  const Photo({
    required this.id,
    required this.createdAt,
    required this.updatedAt,
    required this.shotAt,
    required this.url,
    required this.userId,
  });

  final String id;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime shotAt;
  final String url;
  final String userId;
}

/// [Photo]用コレクションのためのレファレンス
CollectionReference<Photo> photosRef({required String userId}) {
  return FirebaseFirestore.instance
      .collection('users')
      .doc(userId)
      .collection('photos')
      .withConverter<Photo>(
    fromFirestore: ((snapshot, _) {
      return Photo(
        id: snapshot.id,
        createdAt: snapshot.data()!['createdAt'].toDate(),
        updatedAt: snapshot.data()!['updatedAt'].toDate(),
        shotAt: snapshot.data()!['shotAt'].toDate(),
        url: snapshot.data()!['url'],
        userId: snapshot.data()!['userId'],
      );
    }),
    toFirestore: (photo, _) {
      return {
        'createdAt': photo.createdAt,
        'updatedAt': photo.updatedAt,
        'url': photo.url,
        'userId': photo.userId,
      };
    },
  );
}
