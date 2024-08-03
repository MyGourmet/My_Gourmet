import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:go_router/go_router.dart';

import '../core/database/database.dart';
import '../features/auth/auth_controller.dart';
import '../features/auth/authed_user.dart';
import '../features/home/home_controller.dart';
import '../features/photo/photo_controller.dart';

class HomePage extends ConsumerStatefulWidget {
  const HomePage({super.key});

  static const routeName = 'home_page';
  static const routePath = '/home_page';

  @override
  ConsumerState<HomePage> createState() => _HomePageState();
}

class _HomePageState extends ConsumerState<HomePage>
    with SingleTickerProviderStateMixin {
  late Future<List<Photo>> _photos;
  late Future<List<Size>> _sizes;
  late TabController _tabController;
  bool isLoading = false;
  bool isReady = false;

  @override
  void initState() {
    super.initState();
    _photos = ref.read(homeControllerProvider).getPhotos();
    _tabController = TabController(length: 6, vsync: this);
    _initDownloadPhotos();
  }

  Future<void> _initDownloadPhotos() async {
    debugPrint('_initDownloadPhotos start!!!');

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

  List<String>? photoUrls; // Firebaseからダウンロードした写真のURLを保持

  Future<void> _downloadPhotos(WidgetRef ref) async {
    debugPrint('_downloadPhotos start!!!');
    final userId = ref.watch(userIdProvider);

    if (userId == null) {
      debugPrint('User is not signed in');
      return;
    }

    final result = await ref.read(photoControllerProvider).downloadPhotos(
          userId: userId,
        );

    setState(() {
      photoUrls =
          result.map((e) => e.url).where((url) => url.isNotEmpty).toList();
      debugPrint('photoUrls: $photoUrls');
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
                labelPadding: const EdgeInsets.only(
                    left: 0.0, right: 20.0), // ここでラベルの左側のパディングを調整
                indicatorPadding: const EdgeInsets.only(
                    left: 0.0, right: 20.0), // インジケーターの左側のパディングを調整
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
            _buildPhotoGrid(context),
            Container(child: Text('ラーメン')),
            Container(child: Text('カフェ')),
            Container(child: Text('和食')),
            Container(child: Text('洋食')),
            Container(child: Text('エスニック')),
          ],
        ),
      ),
    );
  }

  Widget _buildPhotoGrid(BuildContext context) {
    if (photoUrls == null) {
      return const Center(child: CircularProgressIndicator());
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: MasonryGridView.count(
        crossAxisCount: 2,
        mainAxisSpacing: 8,
        crossAxisSpacing: 8,
        itemBuilder: (context, index) {
          final photoUrl = photoUrls![index];
          return Hero(
            tag: photoUrl,
            child: GestureDetector(
              onTap: () {
                context.push(
                  '/image_detail',
                  extra: {
                    'heroImageFile': photoUrl,
                    'photoFileList': photoUrls,
                    'index': index,
                  },
                );
              },
              child: Container(
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
                    photoUrl,
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            ),
          );
        },
        itemCount: photoUrls!.length,
      ),
    );
  }
}
