import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:photo_manager/photo_manager.dart';

class HomePage extends HookWidget {
  const HomePage({super.key});

  static const routeName = 'home_page';
  static const routePath = '/home_page';

  @override
  Widget build(BuildContext context) {
    final photoUrls = useState<List<String>>([]);
    final selectedImages = useState<List<AssetEntity>>([]);
    final isImagePickerVisible = useState(false); // 写真一覧表示の制御

    // ダミーデータとして表示する既存の画像リスト
    useEffect(() {
      photoUrls.value = [
        "https://placehold.jp/150x150.png",
        "https://placehold.jp/150x150.png",
        "https://placehold.jp/150x150.png",
      ];
      return null;
    }, []);

    return Scaffold(
      appBar: AppBar(
        title: const Text('ホームページ'),
      ),
      body: Stack(
        children: [
          Column(
            children: [
              Expanded(
                child: _buildPhotoGrid(context, photoUrls.value),
              ),
              const Divider(),
              Expanded(
                child: _buildSelectedImagesList(selectedImages.value),
              ),
            ],
          ),
          if (isImagePickerVisible.value)
            Positioned.fill(
              child: _buildImagePickerOverlay(
                context,
                isImagePickerVisible,
                selectedImages,
              ),
            ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final hasPermission = await _checkPhotoPermission(context);
          if (hasPermission) {
            isImagePickerVisible.value = true;
          }
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  Future<bool> _checkPhotoPermission(BuildContext context) async {
    final PermissionState permissionState =
        await PhotoManager.requestPermissionExtend();
    if (!permissionState.isAuth) {
      await PhotoManager.openSetting();
      return false;
    }
    return true;
  }

  Widget _buildImagePickerOverlay(
    BuildContext context,
    ValueNotifier<bool> isImagePickerVisible,
    ValueNotifier<List<AssetEntity>> selectedImages,
  ) {
    final photoAssets = useState<List<AssetEntity>>([]);

    useEffect(() {
      PhotoManager.getAssetPathList(type: RequestType.image)
          .then((albums) async {
        if (albums.isNotEmpty) {
          final photos = await albums[0].getAssetListPaged(page: 0, size: 100);
          photoAssets.value = photos;
        }
      });
      return null;
    }, []);

    return Material(
      color: Colors.black54,
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                const Text(
                  '写真を選択',
                  style: TextStyle(color: Colors.white, fontSize: 18),
                ),
                const Spacer(),
                IconButton(
                  icon: const Icon(Icons.close, color: Colors.white),
                  onPressed: () {
                    isImagePickerVisible.value = false; // 写真一覧を閉じる
                  },
                ),
              ],
            ),
          ),
          Expanded(
            child: GridView.builder(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 4,
                mainAxisSpacing: 4,
                crossAxisSpacing: 4,
              ),
              itemCount: photoAssets.value.length,
              itemBuilder: (context, index) {
                final photo = photoAssets.value[index];
                return FutureBuilder<Uint8List?>(
                  future: photo.thumbnailData,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(
                        child: CircularProgressIndicator(),
                      );
                    }

                    final data = snapshot.data;
                    if (data == null) {
                      return const SizedBox();
                    }

                    return GestureDetector(
                      onTap: () {
                        selectedImages.value = [...selectedImages.value, photo];
                        isImagePickerVisible.value = false; // 写真一覧を閉じる
                      },
                      child: Image.memory(
                        data,
                        fit: BoxFit.cover,
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPhotoGrid(BuildContext context, List<String> photoUrls) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 6),
      child: MasonryGridView.count(
        crossAxisCount: 2,
        mainAxisSpacing: 6,
        crossAxisSpacing: 6,
        itemBuilder: (context, index) {
          final photoUrl = photoUrls[index];
          return Container(
            decoration: BoxDecoration(
              image: DecorationImage(
                image: NetworkImage(photoUrl),
                fit: BoxFit.cover,
              ),
              border: Border.all(color: Colors.grey, width: 2),
              borderRadius: BorderRadius.circular(8),
            ),
            height: 200,
          );
        },
        itemCount: photoUrls.length,
      ),
    );
  }

  Widget _buildSelectedImagesList(List<AssetEntity> selectedImages) {
    if (selectedImages.isEmpty) {
      return const Center(
        child: Text('選択された画像はありません'),
      );
    }

    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: GridView.builder(
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 4,
          mainAxisSpacing: 4,
          crossAxisSpacing: 4,
        ),
        itemCount: selectedImages.length,
        itemBuilder: (context, index) {
          final image = selectedImages[index];
          return FutureBuilder<Uint8List?>(
            future: image.thumbnailData,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(
                  child: CircularProgressIndicator(),
                );
              }

              final thumbnailData = snapshot.data;
              if (thumbnailData == null) {
                return const SizedBox();
              }

              return Image.memory(
                thumbnailData,
                fit: BoxFit.cover,
              );
            },
          );
        },
      ),
    );
  }
}
