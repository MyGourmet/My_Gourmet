import 'package:appinio_swiper/appinio_swiper.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/permission_service.dart';
import '../core/themes.dart';
import '../features/swipe_photo/swipe_photo_controller.dart';
import 'widgets/photo_cards.dart';

/// 写真スワイプページ
class SwipePhotoPage extends ConsumerStatefulWidget {
  const SwipePhotoPage({super.key});

  static const routeName = 'swipe_photo_page';
  static const routePath = '/swipe_photo_page';

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => SwipePhotoPageState();
}

class SwipePhotoPageState extends ConsumerState<SwipePhotoPage> {
  final controller = AppinioSwiperController();
  static const textStyle = TextStyle(
    fontSize: 22,
    fontWeight: FontWeight.bold,
    color: Themes.grayPrimaryColor,
  );

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: Column(
          children: [
            const SizedBox(height: 8),
            _buildCount(),
            Expanded(
              child: _buildPhotoContainer(),
            ),
          ],
        ),
      ),
    );
  }

  /// カウント数
  Widget _buildCount() {
    return Consumer(
      builder: (context, ref, child) {
        final photoCount = ref.watch(photoCountProvider);
        return photoCount != null
            ? Center(
                child: Text(
                  '${photoCount.current}枚 / ${photoCount.total}枚',
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Themes.grayPrimaryColor,
                  ),
                ),
              )
            : const SizedBox();
      },
    );
  }

  /// 写真表示
  Widget _buildPhotoContainer() {
    return Center(
      // 写真リスト監視
      child: ref.watch(photoListProvider).when(
            data: (photos) {
              if (photos.isEmpty) {
                return _buildComplete();
              }

              return Column(
                children: [
                  Expanded(
                    child: PhotoCards(
                      controller: controller,
                      photos: photos,
                    ),
                  ),
                  _buildButtons(),
                ],
              );
            },
            error: (error, stackTrace) {
              return _buildError(error);
            },
            loading: () => const CircularProgressIndicator(),
          ),
    );
  }

  /// スワイプボタン
  Widget _buildButtons() {
    return SizedBox(
      height: 80,
      child: Padding(
        padding: const EdgeInsets.only(left: 8, top: 16, right: 8, bottom: 4),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Flexible(
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                    side: const BorderSide(
                      width: 2,
                      color: Themes.grayPrimaryColor,
                    ),
                  ),
                  backgroundColor: Themes.mainOrange.shade50,
                  foregroundColor: Themes.grayPrimaryColor,
                ),
                onPressed: controller.swipeLeft,
                child: const Text(
                  'スキップ',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ),
            ),
            const SizedBox(
              width: 12,
            ),
            Flexible(
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                    side: const BorderSide(
                      width: 2,
                      color: Themes.grayPrimaryColor,
                    ),
                  ),
                  foregroundColor: Colors.white,
                ),
                onPressed: controller.swipeRight,
                child: const Text(
                  'ご飯',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// 処理完了
  Widget _buildComplete() {
    return const SizedBox(
      width: 232,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '保存が完了しました！',
            style: textStyle,
          ),
          SizedBox(
            height: 16,
          ),
          Row(
            children: [
              Text(
                'さっそく',
                style: textStyle,
              ),
              Column(
                children: [
                  Icon(
                    Icons.photo_outlined,
                    color: Themes.grayPrimaryColor,
                    size: 18,
                  ),
                  Text(
                    'ギャラリー',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: Themes.grayPrimaryColor,
                    ),
                  ),
                ],
              ),
            ],
          ),
          Text(
            'を確認しましょう！',
            style: textStyle,
          ),
        ],
      ),
    );
  }

  /// エラー
  Widget _buildError(Object error) {
    if (error is PermissionException) {
      return const Text('権限がありません。', style: textStyle);
    }
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        IconButton(
          onPressed: () => ref.read(photoListProvider.notifier).forceRefresh(),
          icon: const Icon(Icons.refresh, color: Themes.grayPrimaryColor),
        ),
        const Text('エラーが発生しました。', style: textStyle),
      ],
    );
  }
}
