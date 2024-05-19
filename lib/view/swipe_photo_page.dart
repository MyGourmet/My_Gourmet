import 'package:appinio_swiper/appinio_swiper.dart';
import 'package:confetti/confetti.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';

import '../core/build_context_extension.dart';
import '../core/exception.dart';
import '../core/themes.dart';
import '../features/swipe_photo/swipe_photo_controller.dart';
import 'widgets/custom_elevated_button.dart';
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
  /// スワイプ用のコントローラー
  final _swiperController = AppinioSwiperController();

  /// 完了アニメーション用のコントローラー
  final _confettiController =
      ConfettiController(duration: const Duration(seconds: 5));

  /// アニメーションを行うかどうか
  /// 既にスワイプ完了していたらアニメーションを行わない
  bool isAnimation = false;

  /// スワイプ可能かどうか
  bool isSwipe = true;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: Column(
          children: [
            const Gap(8),
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
                  style: context.textTheme.titleMedium,
                ),
              )
            : const SizedBox.shrink();
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

              isAnimation = true;

              return Stack(
                children: [
                  Padding(
                    padding: const EdgeInsets.only(
                      left: 8,
                      right: 8,
                      bottom: 32,
                    ),
                    child: PhotoCards(
                      controller: _swiperController,
                      photos: photos,
                    ),
                  ),
                  Positioned(
                    bottom: 0,
                    child: _buildButtons(),
                  ),
                ],
              );
            },
            error: _buildError,
            loading: _buildLoading,
          ),
    );
  }

  /// スワイプボタン
  Widget _buildButtons() {
    return SizedBox(
      width: context.screenWidth,
      height: 80,
      child: Padding(
        padding: const EdgeInsets.only(left: 8, top: 16, right: 8, bottom: 4),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Flexible(
              fit: FlexFit.tight,
              child: CustomElevatedButton(
                onPressed: () => _guardSwipe(_swiperController.swipeLeft),
                text: 'ちがう',
                backgroundColor: Themes.gray.shade200,
                textColor: Themes.gray.shade900,
                height: 56,
                width: 150,
                widget: Icon(
                  Icons.close,
                  color: Themes.gray.shade900,
                ),
              ),
            ),
            const Gap(32),
            Flexible(
              fit: FlexFit.tight,
              child: CustomElevatedButton(
                onPressed: () => _guardSwipe(_swiperController.swipeRight),
                text: 'グルメ',
                height: 56,
                width: 150,
                widget: Image.asset(
                  'assets/images/gourmet.png',
                  width: 32,
                  height: 32,
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
    final text = Text(
      '全ての写真を分類しました！',
      style: context.textTheme.titleMedium,
    );

    if (isAnimation) {
      if (_confettiController.state.name == 'stopped') {
        _confettiController.play();
      }

      return Stack(
        alignment: Alignment.center,
        children: [
          Align(
            alignment: Alignment.topCenter,
            child: ConfettiWidget(
              confettiController: _confettiController,
              blastDirectionality: BlastDirectionality.explosive,
              blastDirection: 0,
              emissionFrequency: 0.2,
              minimumSize: const Size(10, 10),
              maximumSize: const Size(50, 50),
              numberOfParticles: 1,
              colors: [
                Themes.mainOrange,
                Themes.mainOrange.shade50,
                Themes.mainOrange.shade100,
                Themes.gray,
                Themes.gray.shade200,
                Themes.gray.shade400,
              ], // manually specify the colors to be used
            ),
          ),
          text,
          Positioned(
            bottom: context.screenHeight * 0.25,
            child: Column(
              children: [
                Text(
                  '追加された写真',
                  style: context.textTheme.bodyMedium
                      ?.copyWith(color: Themes.gray.shade400),
                ),
                const Gap(8),
                ref.watch(foodPhotoCountProvider).when(
                      data: (count) {
                        return Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(
                              Icons.add,
                              color: Themes.mainOrange,
                            ),
                            Padding(
                              padding:
                                  const EdgeInsets.only(left: 16, bottom: 2),
                              child: Text(
                                '$count 枚',
                                style:
                                    context.textTheme.headlineSmall?.copyWith(
                                  color: Themes.mainOrange,
                                ),
                              ),
                            ),
                          ],
                        );
                      },
                      error: _buildError,
                      loading: _buildLoading,
                    ),
              ],
            ),
          ),
        ],
      );
    }

    return Center(
      child: text,
    );
  }

  /// エラー
  Widget _buildError(Object error, StackTrace _) {
    if (error is PermissionException) {
      return Text('権限がありません。', style: context.textTheme.titleMedium);
    }
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        IconButton(
          onPressed: () => ref.read(photoListProvider.notifier).forceRefresh(),
          icon: Icon(Icons.refresh, color: Themes.gray.shade500),
        ),
        Text('エラーが発生しました。', style: context.textTheme.titleMedium),
      ],
    );
  }

  /// ローディング
  Widget _buildLoading() => const CircularProgressIndicator();

  /// スワイプボタン連打防止
  Future<void> _guardSwipe(Future<void> Function() execute) async {
    if (isSwipe) {
      setState(() => isSwipe = false);
      await execute();
      await Future<void>.delayed(
        const Duration(milliseconds: 300),
      );
      setState(() => isSwipe = true);
    }
  }

  /// 終了処理
  @override
  void dispose() {
    super.dispose();
    _swiperController.dispose();
    _confettiController.dispose();
  }
}
