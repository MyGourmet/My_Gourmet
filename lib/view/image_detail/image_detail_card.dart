import 'package:flip_card/flip_card.dart';
import 'package:flutter/material.dart';

import 'card_back.dart';
import 'card_front.dart';

class ImageDetailCard extends StatefulWidget {
  const ImageDetailCard(
      {super.key,
      required this.storeName,
      required this.dateTime,
      required this.address,
      required this.photoUrl,
      required this.storeUrl,
      required this.storeImageUrls});

  final String storeName;
  final DateTime dateTime;
  final String address;
  final String photoUrl;
  final String storeUrl;
  final List<String> storeImageUrls;

  @override
  State<ImageDetailCard> createState() => _ImageDetailCardState();
}

class _ImageDetailCardState extends State<ImageDetailCard> {
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
