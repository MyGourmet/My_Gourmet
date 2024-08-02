import 'dart:io';

import 'package:flutter/material.dart';
import 'package:gap/gap.dart';

import '../../core/build_context_extension.dart';
import '../../core/themes.dart';
import '../widgets/custom_elevated_button.dart';
import '../widgets/scalable_image.dart';

List<File> shopList = [];
int shopNo = 0;
int shopNoSelected = 0;

Future<void> showShopListDialog(
  BuildContext context, {
  required String shopName,
  required List<File> imageFileList,
  required void Function() onSelected,
}) async {
  await showDialog<void>(
    context: context,
    barrierDismissible: false,
    builder: (BuildContext context) {
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
                    icon: Icon(Icons.close, size: 20, color: Themes.gray[800]),
                  ),
                ),
              ),
              const Gap(24),
              Text(
                '写真を撮った店舗を選んでください',
                style: context.textTheme.titleSmall,
              ),
              const Gap(10),
              for (shopNo = 0; shopNo < 3; shopNo++) ...{
                Stack(
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
                                shopName,
                                style: context.textTheme.bodySmall,
                              ),
                            ),
                          ),
                          SizedBox(
                            height: 110,
                            child: Scrollbar(
                              child: ListView.builder(
                                scrollDirection: Axis.horizontal,
                                itemCount: imageFileList.length,
                                itemBuilder: (context, index) {
                                  return Padding(
                                    padding: const EdgeInsets.only(left: 10),
                                    child: ClipRRect(
                                      borderRadius: BorderRadius.circular(0),
                                      child: ScalableImage(
                                        imageFile: imageFileList[index],
                                        height: 100,
                                        width: 125,
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
              },
              const Gap(10),
              const Align(
                alignment: Alignment.centerRight,
                child: Text('次の３店鋪'),
              ),
              const Gap(16),
              Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: context.screenWidth * 0.05,
                ),
                child: SizedBox(
                  height: 60,
                  child: CustomElevatedButton(
                    onPressed: onSelected,
                    text: '決定',
                  ),
                ),
              ),
              const Gap(24),
            ],
          ),
        ),
      );
    },
  );
}
