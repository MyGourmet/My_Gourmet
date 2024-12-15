import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:image_picker/image_picker.dart';
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
                    'スマホに入っている写真を読み込みます！',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  Text(
                    'グルメの画像とそれ以外を分類してください。',
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

                    // コンソールに選択された画像の情報を表示
                    print('選択された画像一覧:');
                    for (final image in images) {
                      print('画像パス: ${image.path}');
                    }

                    // 位置情報を取得
                    final locations = <Map<String, double>>[];
                    for (final image in images) {
                      final location = await ref
                          .read(photoListProvider.notifier)
                          .getImageLocation(image.path);
                      if (location != null) {
                        locations.add(location);
                        // コンソールに位置情報を表示
                        print(
                            '画像の位置情報 - 緯度: ${location['latitude']}, 経度: ${location['longitude']}');
                      }
                    }

                    // 位置情報を保存
                    ref.read(imageLocationsProvider.notifier).state = locations;
                  }
                },
                child: const Text('分類スタート'),
              ),
            ),
            const Gap(16),
            Consumer(
              builder: (context, ref, _) {
                final locations = ref.watch(imageLocationsProvider);
                return locations.isNotEmpty
                    ? Expanded(
                        child: ListView.builder(
                          itemCount: locations.length,
                          itemBuilder: (context, index) {
                            final location = locations[index];
                            return ListTile(
                              title: Text('画像 $index の位置情報:'),
                              subtitle: Text(
                                '緯度: ${location['latitude']}, 経度: ${location['longitude']}',
                              ),
                            );
                          },
                        ),
                      )
                    : const Text('位置情報が取得できた画像はありません');
              },
            ),
          ],
        ),
      ),
    );
  }
}
