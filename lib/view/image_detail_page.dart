import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../core/themes.dart';
import '../features/auth/auth_controller.dart';
import '../features/photo/photo.dart';
import '../features/photo/photo_controller.dart';
import '../features/store/store.dart';
import '../features/store/store_controller.dart';
import 'image_detail/image_detail_card.dart';

class ImageDetailPage extends ConsumerStatefulWidget {
  const ImageDetailPage({
    super.key,
    required this.index,
    required this.photoId,
  });

  static const String routeName = '/image_detail';
  static const String routePath = '/image_detail';

  final int index;
  final String photoId;

  @override
  ConsumerState<ImageDetailPage> createState() => _ImageDetailPageState();
}

class _ImageDetailPageState extends ConsumerState<ImageDetailPage> {
  late final PageController _pageController;
  late Future<Photo?> _photo;

  @override
  void initState() {
    super.initState();
    _pageController =
        PageController(initialPage: widget.index, viewportFraction: 0.9);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _downloadPhoto(ref);
  }

  void _downloadPhoto(WidgetRef ref) {
    final userId = ref.watch(userIdProvider);

    if (userId == null) {
      return;
    }

    _photo = ref.read(photoControllerProvider).downloadPhoto(
          userId: userId,
          photoId: widget.photoId,
        );
  }

  Future<Store?> _fetchStore(Photo photo) async {
    final storeController = ref.read(storeControllerProvider);
    final userId = FirebaseAuth.instance.currentUser!.uid;

    final storeId = photo.storeId;

    if (storeId.isEmpty) {
      return null;
    }

    return storeController.getStoreById(
      userId: userId,
      storeId: storeId,
    );
  }

  String formatAddress(String fullAddress) {
    final postalCodeIndex = fullAddress.indexOf('〒');

    // もし '〒' が見つからない場合、そのまま fullAddress を返す
    if (postalCodeIndex == -1) {
      return fullAddress;
    }

    // '〒' の次のスペースが見つからない場合、そのまま fullAddress を返す
    final spaceIndex = fullAddress.indexOf(' ', postalCodeIndex);
    if (spaceIndex == -1) {
      return fullAddress;
    }

    final postalCode = fullAddress.substring(postalCodeIndex, spaceIndex);
    final address = fullAddress.substring(spaceIndex + 1);

    return '$postalCode\n$address';
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
        toolbarHeight: 24,
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
            FutureBuilder(
              future: _photo,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                } else if (snapshot.hasData && snapshot.data != null) {
                  final photo = snapshot.data!;
                  final storeFuture = _fetchStore(photo);

                  return FutureBuilder<Store?>(
                    future: storeFuture,
                    builder: (context, storeSnapshot) {
                      if (storeSnapshot.connectionState ==
                          ConnectionState.waiting) {
                        return const Center(child: CircularProgressIndicator());
                      } else if (storeSnapshot.hasError) {
                        return Center(
                          child: Text('Error: ${storeSnapshot.error}'),
                        );
                      } else {
                        final store = storeSnapshot.data;
                        return PageView.builder(
                          controller: _pageController,
                          itemCount: 1,
                          itemBuilder: (context, index) {
                            return Padding(
                              padding: EdgeInsets.only(
                                top: MediaQuery.of(context).size.height * 0.01,
                                bottom:
                                    MediaQuery.of(context).size.height * 0.01,
                                left: 4,
                                right: 4,
                              ),
                              child: ImageDetailCard(
                                userId: photo.userId,
                                photoId: photo.id,
                                areaStoreIds: photo.areaStoreIds,
                                photoUrl: photo.url,
                                storeName: store?.name ?? '',
                                dateTime: DateTime.now(),
                                address: formatAddress(store?.address ?? ''),
                                storeUrl: store?.website ?? '',
                                storeImageUrls: store?.imageUrls ?? [],
                                storeOpeningHours: store?.openingHours ?? {},
                                showCardBack: photo.storeId.isNotEmpty,
                                onSelected: () {
                                  _downloadPhoto(ref);
                                  setState(() {});
                                },
                              ),
                            );
                          },
                        );
                      }
                    },
                  );
                } else {
                  return const Center(
                    child: Text('Nothing photo'),
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
