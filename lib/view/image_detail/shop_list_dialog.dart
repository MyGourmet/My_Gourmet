import 'dart:io';

import 'package:flutter/material.dart';
import 'package:gap/gap.dart';

import '../../core/build_context_extension.dart';
import '../../core/themes.dart';
import '../widgets/custom_elevated_button.dart';
import '../widgets/scalable_photo.dart';

List<File> shopList = [];
int shopNo = 0;
int shopNoSelected = 0;

Future<void> showShopListDialog(
  BuildContext context, {
  required String shopName,
  required List<String> storeImageUrls,
  required void Function() onSelected,
}) async {
  await showDialog<void>(
    context: context,
    barrierDismissible: false,
    builder: (BuildContext context) {
      return Dialog(
        insetPadding: const EdgeInsets.all(16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        child: Stack(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Gap(56),
                  Text(
                    '写真を撮った店舗を選んでください',
                    style: context.textTheme.titleSmall,
                  ),
                  const Gap(24),
                  for (shopNo = 0; shopNo < 3; shopNo++) ...{
                    Stack(
                      children: [
                        Container(
                          margin: const EdgeInsets.only(
                            top: 8,
                            right: 8,
                            bottom: 8,
                          ),
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            border: Border.all(
                              width: 2,
                              color: shopNoSelected == shopNo
                                  ? Themes.mainOrange
                                  : Themes.gray.shade300,
                              strokeAlign: BorderSide.strokeAlignOutside,
                            ),
                            borderRadius: BorderRadius.circular(8),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.grey.withOpacity(0.2),
                                blurRadius: 4,
                                offset: const Offset(4, 4),
                              ),
                            ],
                            color: Colors.white,
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                shopName,
                                style: context.textTheme.bodySmall,
                              ),
                              const Gap(8),
                              SizedBox(
                                height: 110,
                                child: Scrollbar(
                                  child: ListView.separated(
                                    scrollDirection: Axis.horizontal,
                                    itemCount: storeImageUrls.length,
                                    itemBuilder: (context, index) {
                                      return ClipRRect(
                                        borderRadius: BorderRadius.circular(0),
                                        child: const ScalablePhoto(
                                          height: 100,
                                          width: 125,
                                          // TODO(Kim): 各ストアのURLを表示する
                                          photoUrl: '',
                                          zoomButtonSize: 32,
                                        ),
                                      );
                                    },
                                    separatorBuilder:
                                        (BuildContext context, int index) {
                                      return const Gap(8);
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
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton(
                      style: TextButton.styleFrom(
                        foregroundColor: Themes.gray,
                      ),
                      onPressed: () {
                        // TODO(Kim): 各ストアのURLを表示する
                      },
                      child: const Text('次の３店鋪'),
                    ),
                  ),
                  const Gap(16),
                  CustomElevatedButton(
                    onPressed: onSelected,
                    text: '決定',
                  ),
                  const Gap(56),
                ],
              ),
            ),
            Positioned(
              top: 8,
              right: 8,
              child: IconButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                style: ElevatedButton.styleFrom(
                  foregroundColor: Colors.white,
                  backgroundColor: Themes.gray[50],
                  shape: const CircleBorder(),
                ),
                icon: Icon(Icons.close, color: Themes.gray[800]),
              ),
            ),
          ],
        ),
      );
    },
  );
}
