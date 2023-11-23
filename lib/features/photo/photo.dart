import 'package:cloud_firestore/cloud_firestore.dart';

class Photo extends Object {
  const Photo({
    required this.id,
    required this.createdAt,
    required this.updatedAt,
    required this.url,
    required this.userId,
    required this.otherUrls,
  });

  final String id;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String url;
  final String userId;
  final List<String> otherUrls;
}

CollectionReference<Photo> photoCollectionReference({required String userId}) {
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
        url: snapshot.data()!['url'],
        userId: snapshot.data()!['userId'],
        otherUrls: snapshot.data()!['otherUrls'].cast<String>(),
      );
    }),
    toFirestore: (photo, _) {
      return {
        'createdAt': photo.createdAt,
        'updatedAt': photo.updatedAt,
        'url': photo.url,
        'userId': photo.userId,
        'otherUrls': photo.otherUrls,
      };
    },
  );
}
