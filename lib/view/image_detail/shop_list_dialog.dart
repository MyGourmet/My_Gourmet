import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';

import '../../core/build_context_extension.dart';
import '../../core/themes.dart';
import '../../features/photo/photo_controller.dart';
import '../../features/store/store.dart';
import '../widgets/custom_elevated_button.dart';
import '../widgets/scalable_image.dart';

List<File> shopList = [];
int shopNoSelected = 0; // 初期値を0に設定

Future<void> showShopListDialog(
  BuildContext context, {
  required WidgetRef ref,
  required String userId,
  required String photoId,
  required List<Store> stores,
  required void Function() onSelected,
}) async {
  var currentIndex = 0;

  void showNextStores(StateSetter setState) {
    setState(() {
      currentIndex += 3;
      if (currentIndex >= stores.length) {
        currentIndex = 0; // 最後まで行ったら最初に戻る
      }
    });
  }

  await showDialog<void>(
    context: context,
    barrierDismissible: false,
    builder: (BuildContext context) {
      return StatefulBuilder(
        builder: (context, setState) {
          final selectedStores =
              stores.skip(currentIndex).take(3).toList(); // 現在のインデックスから3件を取得
          final storeNames = selectedStores.map((store) => store.name).toList();
          final storeImagesList =
              selectedStores.map((store) => store.imageUrls).toList();
          final selectedStoreId = selectedStores[shopNoSelected].id;

          return AlertDialog(
            insetPadding: const EdgeInsets.all(20),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            content: Container(
              width: context.screenWidth,
              decoration: BoxDecoration(
                border: Border.all(color: Colors.white),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Align(
                    alignment: Alignment.topRight,
                    child: Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        color: Themes.gray[50],
                        shape: BoxShape.circle,
                      ),
                      child: IconButton(
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                        icon: Icon(
                          Icons.close,
                          size: 20,
                          color: Themes.gray[800],
                        ),
                      ),
                    ),
                  ),
                  const Spacer(),
                  Text(
                    '写真を撮った店舗を選んでください',
                    style: context.textTheme.titleSmall,
                  ),
                  const Gap(10),
                  for (int shopNo = 0;
                      shopNo < selectedStores.length;
                      shopNo++) ...{
                    GestureDetector(
                      onTap: () {
                        setState(() {
                          shopNoSelected = shopNo;
                        });
                      },
                      child: Stack(
                        children: [
                          Container(
                            margin: const EdgeInsets.only(
                              top: 7,
                              bottom: 7,
                              left: 10,
                              right: 10,
                            ),
                            padding: const EdgeInsets.only(
                              top: 5,
                              bottom: 10,
                            ),
                            decoration: BoxDecoration(
                              border: Border.all(
                                width: 2,
                                color: shopNoSelected == shopNo
                                    ? Themes.mainOrange
                                    : Themes.gray.shade300,
                              ),
                              borderRadius: BorderRadius.circular(8),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.grey.withOpacity(0.5),
                                  blurRadius: 3,
                                  offset: const Offset(0, 5),
                                ),
                              ],
                              color: Colors.white,
                            ),
                            child: Column(
                              children: [
                                Padding(
                                  padding: const EdgeInsets.only(
                                    left: 10,
                                    bottom: 5,
                                  ),
                                  child: Align(
                                    alignment: Alignment.topLeft,
                                    child: Text(
                                      storeNames[shopNo],
                                      style: context.textTheme.bodySmall,
                                    ),
                                  ),
                                ),
                                SizedBox(
                                  height: 110,
                                  child: Scrollbar(
                                    child: ListView.builder(
                                      scrollDirection: Axis.horizontal,
                                      itemCount: storeImagesList[shopNo].length,
                                      itemBuilder: (context, index) {
                                        final photoUrl =
                                            storeImagesList[shopNo][index];
                                        return Padding(
                                          padding:
                                              const EdgeInsets.only(left: 10),
                                          child: ClipRRect(
                                            borderRadius:
                                                BorderRadius.circular(8),
                                            child: ScalableImage(
                                              height: 100,
                                              width: 125,
                                              photoUrl: photoUrl,
                                            ),
                                          ),
                                        );
                                      },
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          if (shopNo == shopNoSelected)
                            Positioned(
                              right: 0,
                              top: 0,
                              child: Container(
                                width: 28,
                                height: 28,
                                decoration: const BoxDecoration(
                                  color: Themes.mainOrange,
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(
                                  Icons.check,
                                  color: Colors.white,
                                  size: 20,
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                  },
                  const Gap(10),
                  if (stores.length > 3)
                    Align(
                      alignment: Alignment.centerRight,
                      child: TextButton(
                        onPressed: () => showNextStores(setState),
                        child: const Text(
                          '次へ',
                          style: TextStyle(
                            color: Themes.gray,
                          ),
                        ),
                      ),
                    ),
                  const Gap(16),
                  Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: context.screenWidth * 0.05,
                    ),
                    child: SizedBox(
                      height: 44,
                      child: CustomElevatedButton(
                        onPressed: () async {
                          // 決定ボタン押下時にstoreIdを更新
                          await ref
                              .read(photoControllerProvider)
                              .updateStoreIdForPhoto(
                                userId: userId,
                                photoId: photoId,
                                storeId: selectedStoreId,
                              );
                          onSelected();
                        },
                        text: '決定',
                      ),
                    ),
                  ),
                  const Spacer(),
                ],
              ),
            ),
          );
        },
      );
    },
  );
}
