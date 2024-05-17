import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/permission_service.dart';
import '../core/themes.dart';
import '../features/swipe_photo/swipe_photo_controller.dart';
import 'widgets/custom_elevated_button.dart';

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
                  return Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Image.asset(
                        'assets/images/no_photo.png',
                        width: 200,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        '写真がまだありません...',
                        style: Theme.of(context).textTheme.titleSmall,
                      ),
                    ],
                  );
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
                          CustomElevatedButton(
                            onPressed: () {
                              ref.read(photoListProvider.notifier).loadNext();
                            },
                            text: '無視',
                            backgroundColor: Themes.gray[200],
                            textColor: Themes.gray[900],
                            height: 56,
                            width: 150,
                            widget: Icon(
                              Icons.close,
                              color: Themes.gray[900],
                            ),
                          ),
                          const SizedBox(
                            width: 16,
                          ),
                          CustomElevatedButton(
                            onPressed: () {
                              ref.read(photoListProvider.notifier).loadNext(
                                    isFood: true,
                                  );
                            },
                            text: '飯',
                            height: 56,
                            width: 150,
                            widget: Image.asset(
                              'assets/images/meshi.png',
                              width: 32,
                              height: 32,
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
