import 'package:appinio_swiper/appinio_swiper.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:photo_manager/photo_manager.dart';

import '../../core/themes.dart';
import '../../features/swipe_photo/swipe_photo_controller.dart';

/// 写真カードリスト
class PhotoCards extends ConsumerStatefulWidget {
  const PhotoCards({required this.photos, required this.controller, super.key});

  final List<AssetEntity> photos;
  final AppinioSwiperController controller;

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => PhotoCardsState();
}

class PhotoCardsState extends ConsumerState<PhotoCards> {
  @override
  Widget build(BuildContext context) {
    // Tinder風スワイプウィジェット
    return AppinioSwiper(
      controller: widget.controller,
      cardCount: widget.photos.length,
      onSwipeEnd: (
        previousIndex,
        targetIndex,
        activity,
      ) {
        // スワイプ完了イベント
        switch (activity) {
          case Swipe():
            // 左にスワイプしても右にスワイプしてもSwipeになる？のでoffsetから判定
            ref.read(photoListProvider.notifier).loadNext(
                  isFood: activity.currentOffset.dx > 0,
                  index: previousIndex,
                );
          case Unswipe():
          case CancelSwipe():
          case DrivenActivity():
        }
      },
      cardBuilder: (context, index) {
        return _PhotoCard(
          photo: widget.photos[index],
        );
      },
    );
  }
}

/// 写真カード
class _PhotoCard extends ConsumerWidget {
  const _PhotoCard({
    required this.photo,
  });

  /// 写真データ
  final AssetEntity photo;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ref.watch(photoFileCacheProvider(photo)).when(
          data: (file) {
            return SizedBox.expand(
              child: Card(
                margin: const EdgeInsets.only(
                  left: 8,
                  top: 12,
                  right: 8,
                  bottom: 8,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(32),
                  side: const BorderSide(
                    width: 3,
                    color: Themes.grayPrimaryColor,
                  ),
                ),
                clipBehavior: Clip.antiAliasWithSaveLayer,
                child: Image.file(
                  file,
                  fit: BoxFit.cover,
                ),
              ),
            );
          },
          error: (error, stackTrace) {
            const style = TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Themes.grayPrimaryColor,
            );
            return Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  onPressed: () =>
                      ref.read(photoListProvider.notifier).forceRefresh(),
                  icon:
                      const Icon(Icons.refresh, color: Themes.grayPrimaryColor),
                ),
                const Text('エラーが発生しました。', style: style),
              ],
            );
          },
          loading: () => const CircularProgressIndicator(),
        );
  }
}
