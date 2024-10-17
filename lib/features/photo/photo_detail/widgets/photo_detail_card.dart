import 'package:flip_card/flip_card.dart';
import 'package:flutter/material.dart';

import 'card_back.dart';
import 'card_front.dart';

class PhotoDetailCard extends StatelessWidget {
  const PhotoDetailCard({
    super.key,
    required this.isEditing,
    required this.onDelete,
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

  final bool isEditing;
  final VoidCallback onDelete;
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
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        border: Border.all(
          color: isEditing ? Colors.blue : Colors.transparent,
          width: 2,
        ),
      ),
      child: Stack(
        children: [
          FlipCard(
            fill: Fill.fillBack,
            front: CardFront(
              photoUrl: photoUrl,
              storeName: storeName,
              dateTime: dateTime,
              address: address,
              showCardBack: showCardBack,
            ),
            back: CardBack(
              onSelected: onSelected,
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
          ),

          /// 編集モード時に暗くしてゴミ箱アイコンを表示
          if (isEditing)
            Positioned.fill(
              child: Center(
                child: IconButton(
                  icon: const Icon(
                    Icons.delete,
                    size: 50,
                    color: Colors.white,
                  ),
                  onPressed: onDelete, // 削除処理を呼び出す
                ),
              ),
            ),
        ],
      ),
    );
  }
}
