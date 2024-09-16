import 'package:firebase_remote_config/firebase_remote_config.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:go_router/go_router.dart';

import '../../../core/build_context_extension.dart';
import '../../../core/logger.dart';
import '../../../core/themes.dart';
import '../../auth/auth_controller.dart';
import '../../auth/authed_user.dart';
import '../image_detail/image_detail_page.dart';
import '../photo.dart';
import '../photo_controller.dart';

class HomePage extends ConsumerStatefulWidget {
  const HomePage({super.key});

  static const routeName = 'home_page';
  static const routePath = '/home_page';

  @override
  ConsumerState<HomePage> createState() => _HomePageState();
}

class _HomePageState extends ConsumerState<HomePage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  bool isLoading = false;
  bool isReady = false;
  bool isRectangleView = true; // デフォルトで長方形ビューを設定

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 6, vsync: this);
    _initConfig();
    _initDownloadPhotos();
  }

  Future<void> _initConfig() async {
    final rc = FirebaseRemoteConfig.instance;
    try {
      final galleryView = rc.getString('gallery_view');
      setState(() {
        isRectangleView = galleryView == 'rectangle';
      });
    } on Exception catch (e) {
      logger.e('Error fetching remote config: $e');
    }
  }

  Future<void> _initDownloadPhotos() async {
    SchedulerBinding.instance.addPostFrameCallback((_) async {
      final isSignedIn = ref.watch(userIdProvider) != null;
      if (!isSignedIn) {
        setState(() => isReady = true);
        return;
      }
      await ref.watch(authedUserStreamProvider.future);
      final authedUserAsync = ref.watch(authedUserStreamProvider).valueOrNull;
      final isReadyForUse = authedUserAsync?.classifyPhotosStatus ==
          ClassifyPhotosStatus.readyForUse;
      if (!isReadyForUse) {
        setState(() => isReady = true);
        return;
      }

      await _downloadPhotos(ref);
      setState(() => isReady = true);
    });
  }

  List<Photo>? photoUrls; // Firebaseからダウンロードした写真のURLとカテゴリを保持

  Future<void> _downloadPhotos(WidgetRef ref) async {
    // controller内に組み込む
    final userId = ref.watch(userIdProvider);

    if (userId == null) {
      return;
    }

    final result = await ref.read(photoControllerProvider).downloadPhotos(
          userId: userId,
        );
    // controller内に組み込む
    // controller内にwidgetに必要な要素を取得する処理を実装して、それを呼び出すようにする。

    setState(() {
      photoUrls = result.where((e) => e.url.isNotEmpty).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(kToolbarHeight),
        child: AppBar(
          bottom: PreferredSize(
            preferredSize: const Size.fromHeight(0), // TabBarの高さを指定
            child: TabBar(
              padding: const EdgeInsets.only(left: 16, bottom: 8),
              controller: _tabController,
              isScrollable: true,
              tabs: const [
                Tab(text: 'すべて'),
                Tab(text: 'ラーメン'),
                Tab(text: 'カフェ'),
                Tab(text: '和食'),
                Tab(text: '洋食'),
                Tab(text: 'エスニック'),
              ],
            ),
          ),
        ),
      ),
      body: DefaultTabController(
        length: 6,
        child: TabBarView(
          controller: _tabController,
          children: [
            _buildPhotoGrid(context, 'すべて'),
            _buildPhotoGrid(context, 'ramen'),
            _buildPhotoGrid(context, 'cafe'),
            _buildPhotoGrid(context, 'japanese_food'),
            _buildPhotoGrid(context, 'western_food'),
            _buildPhotoGrid(context, 'ethnic'),
          ],
        ),
      ),
    );
  }

  Widget _buildPhotoGrid(BuildContext context, String category) {
    if (photoUrls == null) {
      return const Center(child: CircularProgressIndicator());
    }

    List<Photo> filteredPhotos;
    if (category == 'すべて') {
      filteredPhotos = photoUrls!;
    } else {
      filteredPhotos =
          photoUrls!.where((photo) => photo.category == category).toList();
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 6),
      child: MasonryGridView.count(
        crossAxisCount: 2,
        mainAxisSpacing: 6,
        crossAxisSpacing: 6,
        itemBuilder: (context, index) {
          final photo = filteredPhotos[index];

          return Hero(
            tag: photo,
            child: GestureDetector(
              onTap: () {
                context.push(
                  ImageDetailPage.routePath,
                  extra: {
                    'photoId': photo.id,
                    'index': index,
                  },
                );
              },
              child: Container(
                decoration: BoxDecoration(
                  image: DecorationImage(
                    image: NetworkImage(photo.url),
                    fit: BoxFit.cover,
                    onError: (error, stackTrace) {
                      // 画像が読み込めなかったときの代替表示
                      throw Exception('Error loading image: $error');
                    },
                  ),
                  border: Border.all(
                    color: Themes.gray[900]!,
                    width: 2,
                  ),
                  borderRadius: BorderRadius.circular(8),
                ),
                width: double.infinity,
                height: isRectangleView
                    ? 280 // 長方形の高さ
                    : context.screenWidth / 2 - 12, // 正方形の高さ
              ),
            ),
          );
        },
        itemCount: filteredPhotos.length,
      ),
    );
  }
}
