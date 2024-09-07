import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:camera/camera.dart';
import 'dart:io';
import 'camera_controller.dart'; // ここで新しいファイルをインポート
import 'camera_detail_page.dart';

class CameraPage extends HookConsumerWidget {
  CameraPage({super.key});

  static const routeName = 'camera_page';
  static const routePath = '/camera_page';

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cameraController = ref.watch(cameraControllerProvider);
    final capturedImage = useState<File?>(null);
    final isTakingPicture = useState(false); // 撮影中かどうかを示すフラグ
    final imageDate = useState<String?>(null);

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          title: const Text(''),
          backgroundColor: Colors.white,
        ),
        body: Stack(
          children: [
            Center(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 28),
                child: Column(
                  children: [
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          border: Border.all(
                            width: 2,
                          ),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Column(
                          children: [
                            Expanded(
                              child: DecoratedBox(
                                decoration: BoxDecoration(
                                  border: Border.all(
                                    width: 2,
                                  ),
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(16),
                                  child: cameraController.when(
                                    data: CameraPreview.new,
                                    error: (err, stack) => const Center(
                                      child: Text(''),
                                    ),
                                    loading: () => const Center(
                                      child: CircularProgressIndicator(),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            const Gap(20),
                            cameraController.when(
                              data: (controller) => GestureDetector(
                                onTap: isTakingPicture.value
                                    ? null
                                    : () {
                                        controller.takePictureAndSave(
                                          context,
                                          ref, // WidgetRefをそのまま渡す
                                          capturedImage, // ValueNotifier<File?> をそのまま渡す
                                          isTakingPicture, // ValueNotifier<bool> をそのまま渡す
                                          imageDate, // ValueNotifier<String?> をそのまま渡す
                                        );
                                      },
                                child: Container(
                                  width: 60,
                                  height: 60,
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                      width: 2,
                                    ),
                                  ),
                                  child: Center(
                                    child: Container(
                                      width: 50,
                                      height: 50,
                                      decoration: const BoxDecoration(
                                        color: Colors.black,
                                        shape: BoxShape.circle,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              error: (err, stack) => const Text(''),
                              loading: SizedBox.shrink,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            // 撮影した画像を左下に表示し、下に日付を表示
            if (capturedImage.value != null && imageDate.value != null)
              Positioned(
                bottom: 32,
                left: 24,
                child: GestureDetector(
                  onTap: () {
                    context.push(
                      CameraDetailPage.routePath,
                      extra: {
                        'imageFile': capturedImage.value,
                        'imageDate': imageDate.value,
                      },
                    );
                  },
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        width: 2,
                      ),
                    ),
                    padding: const EdgeInsets.all(8),
                    child: Column(
                      children: [
                        Container(
                          decoration: BoxDecoration(
                            border: Border.all(
                              width: 2,
                            ),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          width: MediaQuery.sizeOf(context).width / 5,
                          height: MediaQuery.sizeOf(context).height / 5,
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(4),
                            child: Image.file(
                              capturedImage.value!,
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                        const Gap(4),
                        SizedBox(
                          width: MediaQuery.sizeOf(context).width / 5,
                          child: Text(
                            imageDate.value!,
                            style: const TextStyle(
                              color: Colors.black,
                              fontSize: 12,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
