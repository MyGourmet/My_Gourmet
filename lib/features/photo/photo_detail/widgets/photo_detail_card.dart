import 'package:flip_card/flip_card.dart';
import 'package:flutter/material.dart';

import 'card_back.dart';
import 'card_front.dart';

class PhotoDetailCard extends StatefulWidget {
  const PhotoDetailCard({
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
    this.showCardBack = true,
    required this.storeOpeningHours,
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
  final bool showCardBack;
  final Map<String, String> storeOpeningHours;

  final void Function() onSelected;

  @override
  State<PhotoDetailCard> createState() => _PhotoDetailCardState();
}

class _PhotoDetailCardState extends State<PhotoDetailCard> {
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

  Map<String, String> get storeOpeningHours => widget.storeOpeningHours;

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
              onSelected: widget.onSelected,
              userId: userId,
              photoId: photoId,
              areaStoreIds: areaStoreIds,
              isLinked: true,
              storeName: storeName,
              storeImageUrls: storeImageUrls,
              address: address,
              storeUrl: storeUrl,
              storeOpeningHours: storeOpeningHours,
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
