import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../core/database/database.dart';
import '../core/themes.dart';
import '../features/photo/photo_controller.dart';
import '../features/store/store.dart';
import '../features/store/store_controller.dart';
import 'image_detail/image_detail_card.dart';

class ImageDetailPage extends ConsumerStatefulWidget {
  const ImageDetailPage({
    super.key,
    required this.heroImageFile,
    required this.photoFileList,
    required this.index,
    required this.photo,
  });

  static const String routeName = '/image_detail';
  static const String routePath = '/image_detail';

  final File heroImageFile;
  final List<File> photoFileList;
  final int index;
  final Photo photo;

  @override
  ConsumerState<ImageDetailPage> createState() => _ImageDetailPageState();
}

class _ImageDetailPageState extends ConsumerState<ImageDetailPage> {
  late final PageController _pageController;
  late Future<Store?> _storeFuture;

  @override
  void initState() {
    super.initState();
    _pageController =
        PageController(initialPage: widget.index, viewportFraction: 0.9);
    _storeFuture = _fetchStore();
  }

  Future<Store?> _fetchStore() async {
    final photoController = ref.read(photoControllerProvider);
    final storeController = ref.read(storeControllerProvider);
    final userId = FirebaseAuth.instance.currentUser!.uid;

    // userIdをコンソールに表示
    print('User ID: $userId');

    final photoId = widget.photo.id; // photo.id が null または空でないことを確認
    print('prevphotoId ${photoId}');
    print('prevphotoId ${widget.photoFileList[0]}');
    if (photoId.isEmpty) {
      throw Exception('Photo ID is null or empty');
    }

    final photo = await photoController.getPhotoById(
      userId: userId,
      photoId: photoId,
    );

    print('Photo ID: ${photoId}');

    final storeId = photo?.storeId ?? '';

    if (storeId.isEmpty) {
      throw Exception('Store ID is null or empty');
    }

    return await storeController.getStoreById(
      userId: userId,
      storeId: storeId,
    );
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
            FutureBuilder<Store?>(
              future: _storeFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                } else if (!snapshot.hasData || snapshot.data == null) {
                  return const Center(
                      child: Text('No store information available'));
                } else {
                  final store = snapshot.data!;
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
                          shopName: store.name,
                          dateTime: DateTime.now(),
                          address: 'Yokohama, kanagawa JAPAN',
                        ),
                      );
                    },
                  );
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}
