import 'package:flip_card/flip_card.dart';
import 'package:flutter/material.dart';

import 'card_back.dart';
import 'card_front.dart';

class ImageDetailCard extends StatefulWidget {
  const ImageDetailCard(
      {super.key,
      required this.shopName,
      required this.dateTime,
      required this.address,
      required this.photoUrl,
      required this.shopUrl,
      required this.imageFileList});

  final String shopName;
  final DateTime dateTime;
  final String address;
  final String photoUrl;
  final String shopUrl;
  final List<String> imageFileList;

  @override
  State<ImageDetailCard> createState() => _ImageDetailCardState();
}

class _ImageDetailCardState extends State<ImageDetailCard> {
  String get shopName => widget.shopName;

  DateTime get dateTime => widget.dateTime;

  String get formattedDate =>
      '${dateTime.year}/${dateTime.month}/${dateTime.day}';

  String get address => widget.address;

  String get photoUrl => widget.photoUrl;

  String get shopUrl => widget.shopUrl;

  List<String> get imageFileList => widget.imageFileList;

  @override
  Widget build(BuildContext context) {
    return FlipCard(
      fill: Fill.fillBack,
      front: CardFront(
        photoUrl: photoUrl,
        shopName: shopName,
        dateTime: dateTime,
        address: address,
      ),
      back: CardBack(
        isLinked: true,
        shopName: shopName,
        imageFileList: imageFileList,
        holiday: '土曜',
        address: address,
        url: shopUrl,
      ),
    );
  }
}
