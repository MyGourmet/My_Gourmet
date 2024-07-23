import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../core/database/database.dart';
import '../core/themes.dart';
import '../features/photo/photo_controller.dart';
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
    final userId = FirebaseAuth.instance.currentUser!.uid;

    // userIdをコンソールに表示
    print('User ID: $userId');

    final photoId = widget.photo.id; // photo.id が null または空でないことを確認
    print('prevphotoId ${photoId}');
    print('prevphotoId ${widget.photoFileList[0]}');
    if (photoId == null || photoId.isEmpty) {
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
            FutureBuilder<String>(
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
          ],
        ),
      ),
    );
  }
}
