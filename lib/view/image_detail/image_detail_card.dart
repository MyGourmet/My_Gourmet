import 'package:flip_card/flip_card.dart';
import 'package:flutter/material.dart';

import 'card_back.dart';
import 'card_front.dart';

class ImageDetailCard extends StatefulWidget {
  const ImageDetailCard({
    super.key,
    required this.index,
    required this.heroIndex,
    required this.heroImagePath,
    required this.imagePath,
    required this.shopName,
    required this.dateTime,
    required this.address,
  });

  final int index;
  final int heroIndex;
  final String heroImagePath;
  final String imagePath;
  final String shopName;
  final DateTime dateTime;
  final String address;

  @override
  State<ImageDetailCard> createState() => _ImageDetailCardState();
}

class _ImageDetailCardState extends State<ImageDetailCard> {
  String get imagePath => widget.imagePath;

  String get shopName => widget.shopName;

  DateTime get dateTime => widget.dateTime;

  String get formattedDate =>
      '${dateTime.year}/${dateTime.month}/${dateTime.day}';

  String get address => widget.address;

  @override
  Widget build(BuildContext context) {
    final heroImagePath =
        (widget.index == widget.heroIndex) ? widget.heroImagePath : null;

    return FlipCard(
        fill: Fill.fillBack,
        front: CardFront(
          heroImagePath: heroImagePath,
          imagePath: imagePath,
          shopName: shopName,
          dateTime: dateTime,
          address: address,
        ),
        back: CardBack(
          isLinked: true,
          shopName: shopName,
          imagePathList: [
            imagePath,
            imagePath,
            imagePath,
          ],
          holiday: '土曜',
          address: address,
          url: 'https://example.com',
        ));
  }
}
