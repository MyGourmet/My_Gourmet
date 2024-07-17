import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../core/themes.dart';
import '../features/photo/photo_controller.dart';
import 'image_detail/image_detail_card.dart';

class ImageDetailPage extends StatefulWidget {
  const ImageDetailPage({
    super.key,
    required this.heroImageFile,
    required this.photoFileList,
    required this.index,
  });

  static const String routeName = '/image_detail';
  static const String routePath = '/image_detail';

  final File heroImageFile;
  final List<File> photoFileList;
  final int index;

  @override
  State<ImageDetailPage> createState() => _ImageDetailPageState();
}

class _ImageDetailPageState extends State<ImageDetailPage> {
  int get index => widget.index;
  late final PageController _pageController;
  late List<String> shopNames;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: index, viewportFraction: 0.9);

    shopNames = List<String>.filled(widget.photoFileList.length, 'Loading...');
    _fetchShopNames();
  }

  void _fetchShopNames() async {
    final container = ProviderContainer();
    final photoController = container.read(photoControllerProvider);

    // todo widget.photoFileList（今回必要な写真を含めたhome_page.dartに表示されている写真全部）は不要なのでfor文を削除
    for (var i = 0; i < widget.photoFileList.length; i++) {
      // todo photoIdを取得する
      //  - home_page.dart内の`getPhotos`メソッドで取得しているPhotoクラスのidがfirestoreのidと同一であることを確認
      //  ← 実際に動作確認してみる or 登録する際の処理を見る(swipe_photo_page.dartのスワイプ時の挙動を確認）
      //  - 同一であれば、このページに渡して以下で利用する
      // todo firestoreから特定の1枚の写真を取得する & storeIdを取得する
      final photo = await photoController.downloadPhotos(
          userId: FirebaseAuth.instance.currentUser!.uid);

      // todo storeIdから店舗名を取得する
      final storeName = await photoController
          .getStoreNameFromStoreId('ChIJ38OBKhqMGGARv2PCpjtd6uI');
      // photo.storeId
      setState(() {
        shopNames[i] = storeName;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
      ),
      body: Center(
        child: Stack(
          children: [
            Positioned(
              bottom: 0,
              child: Container(
                // padding: EdgeInsets.only(
                //   top: MediaQuery.of(context).size.height * 0.3,
                // ),
                width: MediaQuery.of(context).size.width,
                color: Themes.mainOrange[50],
              ),
            ),
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                itemCount: widget.photoFileList.length,
                itemBuilder: (context, index) {
                  return Padding(
                    padding: EdgeInsets.only(
                      top: MediaQuery.of(context).size.height * 0.01,
                      bottom: MediaQuery.of(context).size.height * 0.01,
                      left: 4,
                      right: 4,
                    ),
                    child: ImageDetailCard(
                      index: index,
                      heroIndex: widget.index,
                      heroImageFile: widget.heroImageFile,
                      imageFile: widget.photoFileList[index],
                      // todo storeNameを渡す
                      shopName: shopNames[index],
                      dateTime: DateTime.now(),
                      address: 'Yokohama, kanagawa JAPAN',
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
