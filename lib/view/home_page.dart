import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:go_router/go_router.dart';

import '../features/auth/auth_controller.dart';
import '../features/auth/authed_user.dart';
import '../features/photo/photo.dart';
import '../features/photo/photo_controller.dart';
import 'image_detail_page.dart';

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

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 6, vsync: this);
    _initDownloadPhotos();
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
    final userId = ref.watch(userIdProvider);

    if (userId == null) {
      return;
    }

    final result = await ref.read(photoControllerProvider).downloadPhotos(
          userId: userId,
        );

    setState(() {
      photoUrls = result.where((e) => e.url.isNotEmpty).toList();
      debugPrint('photoUrls: $photoUrls');
      debugPrint('result: $result');
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
            child: Container(
              alignment: Alignment.centerLeft, // TabBarを左に寄せる
              child: TabBar(
                controller: _tabController,
                isScrollable: true,
                // padding: const EdgeInsets.only(left: 0, right: 0), //,
                tabAlignment: TabAlignment.start,
                labelPadding: const EdgeInsets.only(
                  left: 12,
                  right: 12,
                ), // ここでラベルの左側のパディングを調整
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
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: MasonryGridView.count(
        crossAxisCount: 2,
        mainAxisSpacing: 8,
        crossAxisSpacing: 8,
        itemBuilder: (context, index) {
          final photo = filteredPhotos[index];

          return Hero(
            tag: photo,
            child: GestureDetector(
              onTap: () {
                context.push(
                  ImageDetailPage.routePath,
                  extra: {
                    'photo': photo,
                    'index': index,
                  },
                );
              },
              child: DecoratedBox(
                decoration: BoxDecoration(
                  border: Border.all(
                    color: Colors.grey,
                    width: 2,
                  ),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(14),
                  child: Image.network(
                    photo.url,
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            ),
          );
        },
        itemCount: filteredPhotos.length,
      ),
    );
  }
}
