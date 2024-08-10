import 'package:flip_card/flip_card.dart';
import 'package:flutter/material.dart';

import 'card_back.dart';
import 'card_front.dart';

class ImageDetailCard extends StatefulWidget {
  const ImageDetailCard({
    super.key,
    required this.onSelected,
    required this.userId,
    required this.photoId,
    required this.areaStoreIds,
    required this.storeName,
    required this.dateTime,
    required this.address,
    required this.photoUrl,
    required this.storeUrl,
    required this.storeImageUrls,
  });

  final String userId;
  final String photoId;
  final List<String> areaStoreIds;
  final String storeName;
  final DateTime dateTime;
  final String address;
  final String photoUrl;
  final String storeUrl;
  final List<String> storeImageUrls;

  final void Function() onSelected;

  @override
  State<ImageDetailCard> createState() => _ImageDetailCardState();
}

class _ImageDetailCardState extends State<ImageDetailCard> {
  String get userId => widget.userId;

  String get photoId => widget.photoId;

  List<String> get areaStoreIds => widget.areaStoreIds;

  String get storeName => widget.storeName;

  DateTime get dateTime => widget.dateTime;

  String get formattedDate =>
      '${dateTime.year}/${dateTime.month}/${dateTime.day}';

  String get address => widget.address;

  String get photoUrl => widget.photoUrl;

  String get storeUrl => widget.storeUrl;

  List<String> get storeImageUrls => widget.storeImageUrls;

  @override
  Widget build(BuildContext context) {
    return FlipCard(
      fill: Fill.fillBack,
      front: CardFront(
        photoUrl: photoUrl,
        storeName: storeName,
        dateTime: dateTime,
        address: address,
      ),
      back: CardBack(
        onSelected: widget.onSelected,
        userId: userId,
        photoId: photoId,
        areaStoreIds: areaStoreIds,
        isLinked: true,
        storeName: storeName,
        storeImageUrls: storeImageUrls,
        holiday: '土曜',
        address: address,
        storeUrl: storeUrl,
      ),
    );
  }
}
