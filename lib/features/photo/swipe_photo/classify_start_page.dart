import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import '../../../core/logger.dart';
import 'swipe_photo_controller.dart';

/// 画像の位置情報を管理する状態プロバイダ
final imageLocationsProvider =
    StateProvider<List<Map<String, double>>>((ref) => []);

/// 写真分類開始画面
class ClassifyStartPage extends ConsumerWidget {
  const ClassifyStartPage({super.key});

  static const routeName = 'classify_start_page';
  static const routePath = '/classify_start_page';

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    /// 選択された画像のリストを保持する状態プロバイダ
    final selectedImagesProvider = StateProvider<List<XFile>>((ref) => []);

    return SafeArea(
      child: Scaffold(
        body: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Image.asset(
                    width: 300,
                    height: 350,
                    'assets/images/classify_photo.png',
                  ),
                  const Gap(16),
                  Text(
                    'スマホに入っているグルメ写真を読み込みます！',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  Text(
                    'グルメの画像を選択してください。',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: ElevatedButton(
                onPressed: () async {
                  final imagePicker = ImagePicker();
                  final images = await imagePicker.pickMultiImage();

                  if (images.isNotEmpty) {
                    ref.read(selectedImagesProvider.notifier).state = images;
                    
                    for (final image in images) {
                      try {
                        await ref.read(photoListProvider.notifier).swipeRight(
                              image: image,
                            );
                      } on Exception catch (e) {
                        logger.e('右スワイプ中にエラーが発生しました。: $e');
                      }
                    }
                  }
                },
                child: const Text('追加スタート'),
              ),
            ),
            const Gap(16),
            Consumer(
              builder: (context, ref, _) {
                final selectedImages = ref.watch(selectedImagesProvider);
                return selectedImages.isNotEmpty
                    ? Text(
                        '${selectedImages.length} 枚追加しました',
                        style: Theme.of(context).textTheme.titleMedium,
                      )
                    : const SizedBox.shrink();
              },
            ),
            const Gap(18),
          ],
        ),
      ),
    );
  }
}
