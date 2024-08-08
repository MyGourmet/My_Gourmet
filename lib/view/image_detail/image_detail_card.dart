import 'package:flip_card/flip_card.dart';
import 'package:flutter/material.dart';

import 'card_back.dart';
import 'card_front.dart';

class ImageDetailCard extends StatefulWidget {
  const ImageDetailCard({
    super.key,
    this.storeName = '',
    required this.dateTime,
    this.address = '',
    this.photoUrl = '',
    this.storeUrl = '',
    this.storeImageUrls = const [],
    this.showCardBack = true,
  });

  final String? storeName;
  final DateTime dateTime;
  final String? address;
  final String photoUrl;
  final String? storeUrl;
  final List<String>? storeImageUrls;
  final bool showCardBack;

  @override
  State<ImageDetailCard> createState() => _ImageDetailCardState();
}

class _ImageDetailCardState extends State<ImageDetailCard> {
  String get storeName => widget.storeName ?? '';

  DateTime get dateTime => widget.dateTime;

  String get formattedDate =>
      '${dateTime.year}/${dateTime.month}/${dateTime.day}';

  String get address => widget.address ?? '';

  String get photoUrl => widget.photoUrl;

  String get storeUrl => widget.storeUrl ?? '';

  List<String> get storeImageUrls => widget.storeImageUrls ?? [];

  bool get showCardBack => widget.showCardBack;

  @override
  Widget build(BuildContext context) {
    return showCardBack
        ? FlipCard(
            fill: Fill.fillBack,
            front: CardFront(
              photoUrl: photoUrl,
              storeName: storeName,
              dateTime: dateTime,
              address: address,
              showCardBack: showCardBack,
            ),
            back: CardBack(
              isLinked: true,
              storeName: storeName,
              storeImageUrls: storeImageUrls,
              holiday: '土曜',
              address: address,
              storeUrl: storeUrl,
            ),
          )
        : CardFront(
            photoUrl: photoUrl,
            storeName: storeName,
            dateTime: dateTime,
            address: address,
            showCardBack: showCardBack,
          );
  }
}
