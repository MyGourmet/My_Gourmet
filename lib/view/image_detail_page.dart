import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../core/themes.dart';
import '../features/photo/photo_controller.dart';
import 'image_detail/image_detail_card.dart';

class ImageDetailPage extends ConsumerStatefulWidget {
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
  ConsumerState<ImageDetailPage> createState() => _ImageDetailPageState();
}

class _ImageDetailPageState extends ConsumerState<ImageDetailPage> {
  late final PageController _pageController;
  late Future<String> _storeNameFuture;

  @override
  void initState() {
    super.initState();
    _pageController =
        PageController(initialPage: widget.index, viewportFraction: 0.9);
    _storeNameFuture = _fetchStoreName();
  }

  Future<String> _fetchStoreName() async {
    final photoController = ref.read(photoControllerProvider);
    // todo widget.photoFileList（今回必要な写真を含めたhome_page.dartに表示されている写真全部）は不要なのでfor文を削除
    // ここでphotoIdを取得する必要があります。仮にphotoIdが既知であるとします。
    // todo photoIdを取得する
    //  - home_page.dart内の`getPhotos`メソッドで取得しているPhotoクラスのidがfirestoreのidと同一であることを確認
    //  ← 実際に動作確認してみる or 登録する際の処理を見る(swipe_photo_page.dartのスワイプ時の挙動を確認）
    //  - 同一であれば、このページに渡して以下で利用する
    // todo firestoreから特定の1枚の写真を取得する & storeIdを取得する
    const photoId = "example_photo_id"; // 実際には適切なIDを使用してください。
    final photo = await photoController.getPhotoById(
      userId: FirebaseAuth.instance.currentUser!.uid,
      photoId: photoId,
    );
    // todo storeIdから店舗名を取得する
    final storeId = photo?.storeId ?? '';
    return await photoController.getStoreNameFromStoreId(storeId);
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
                width: MediaQuery.of(context).size.width,
                color: Themes.mainOrange[50],
              ),
            ),
            Expanded(
              child: FutureBuilder<String>(
                future: _storeNameFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  } else if (snapshot.hasError) {
                    return Center(child: Text('Error: ${snapshot.error}'));
                  } else if (!snapshot.hasData) {
                    return const Center(child: Text('No store name available'));
                  } else {
                    final storeName = snapshot.data!;
                    return PageView.builder(
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
                            shopName: storeName,
                            dateTime: DateTime.now(),
                            address: 'Yokohama, kanagawa JAPAN',
                          ),
                        );
                      },
                    );
                  }
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
