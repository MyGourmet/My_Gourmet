import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/permission_service.dart';
import '../features/swipe_photo/swipe_photo_controller.dart';

/// 写真スワイプページ
class SwipePhotoPage extends ConsumerStatefulWidget {
  const SwipePhotoPage({super.key});

  static const routeName = 'swipe_photo_page';
  static const routePath = '/swipe_photo_page';

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => SwipePhotoPageState();
}

class SwipePhotoPageState extends ConsumerState<SwipePhotoPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: Center(
        child: ref.watch(photoListProvider).when(
              data: (photos) {
                if (photos.isEmpty) {
                  return const Text('写真がありません。');
                }

                return Column(
                  children: [
                    Expanded(
                      child: Consumer(
                        builder: (context, ref, _) {
                          final index = ref.watch(photoIndexProvider);

                          return FutureBuilder(
                            future: photos[index].thumbnailData,
                            builder: (context, snapshot) {
                              return snapshot.data != null
                                  ? Card(
                                      margin: const EdgeInsets.all(16),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(32),
                                      ),
                                      clipBehavior: Clip.antiAliasWithSaveLayer,
                                      child: Image.memory(
                                        snapshot.data!,
                                        fit: BoxFit.cover,
                                      ),
                                    )
                                  : const CircularProgressIndicator();
                            },
                          );
                        },
                      ),
                    ),
                    SizedBox(
                      height: 100,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          SizedBox(
                            width: 150,
                            child: ElevatedButton(
                              onPressed: () {
                                ref.read(photoListProvider.notifier).loadNext();
                              },
                              child: const Text('無視'),
                            ),
                          ),
                          const SizedBox(
                            width: 16,
                          ),
                          SizedBox(
                            width: 150,
                            child: ElevatedButton(
                              onPressed: () {
                                ref.read(photoListProvider.notifier).loadNext(
                                      isFood: true,
                                    );
                              },
                              child: const Text('飯'),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                );
              },
              error: (error, stackTrace) {
                if (error is PermissionException) {
                  return const Text('権限がありません。');
                }
                return Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      onPressed: () =>
                          ref.read(photoListProvider.notifier).forceRefresh(),
                      icon: const Icon(Icons.refresh),
                    ),
                    const Text('エラーが発生しました'),
                  ],
                );
              },
              loading: () => const CircularProgressIndicator(),
            ),
      ),
    );
  }
}
