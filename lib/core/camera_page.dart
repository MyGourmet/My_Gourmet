import 'dart:io';
import 'package:camera/camera.dart';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';

import 'package:image_gallery_saver/image_gallery_saver.dart';
import 'package:permission_handler/permission_handler.dart';

import '../logger.dart';
import 'camera_detail_page.dart';

class CameraPage extends ConsumerStatefulWidget {
  const CameraPage({super.key});

  static const routeName = 'camera_page';
  static const routePath = '/camera_page';

  @override
  ConsumerState<CameraPage> createState() => _CameraPageState();
}

class _CameraPageState extends ConsumerState<CameraPage> {
  File? _capturedImage;
  bool _isTakingPicture = false; // 撮影中かどうかを示すフラグ
  String? _imageDate;

  @override
  Widget build(BuildContext context) {
    final cameraController = ref.watch(cameraControllerProvider);

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
                              data: (data) => GestureDetector(
                                onTap: _isTakingPicture
                                    ? null
                                    : () {
                                        onPressTakePictureButton(context, data);
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
            if (_capturedImage != null && _imageDate != null)
              Positioned(
                bottom: 32,
                left: 24,
                child: GestureDetector(
                  onTap: () {
                    context.push(
                      CameraDetailPage.routePath,
                      extra: {
                        'imageFile': _capturedImage,
                        'imageDate': _imageDate,
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
                              _capturedImage!,
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                        const Gap(4),
                        SizedBox(
                          width: MediaQuery.sizeOf(context).width / 5,
                          child: Text(
                            _imageDate!,
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

  /// カメラコントローラ用のプロバイダー
  final cameraControllerProvider =
      FutureProvider.autoDispose<CameraController>((ref) async {
    final cameras = await availableCameras();

    if (cameras.isEmpty) {
      throw CameraException('NoCameraAvailable', '利用可能なカメラが見つかりませんでした');
    }

    final camera = cameras.first;
    final controller = CameraController(
      camera,
      ResolutionPreset.medium,
    );

    ref.onDispose(controller.dispose);

    await controller.initialize();
    return controller;
  });

  /// 写真撮影ボタン押下時処理
  Future<void> onPressTakePictureButton(
    BuildContext context,
    CameraController controller,
  ) async {
    setState(() {
      _isTakingPicture = true; // 撮影中フラグを設定
    });

    try {
      final image = await controller.takePicture();
      await Permission.storage.request();
      await Permission.photos.request();
      await Permission.videos.request();

      if (Platform.isAndroid) {
        if (await Permission.photos.isGranted ||
            await Permission.videos.isGranted ||
            await Permission.storage.isGranted) {
          final result = await ImageGallerySaver.saveFile(image.path);
          logger.i('Image saved to gallery: $result');
        } else {
          logger.e('Permission denied for saving to gallery.');
        }
      } else {
        final result = await ImageGallerySaver.saveFile(image.path);
        logger.i('Image saved to gallery: $result');
      }

      final now = DateTime.now();
      final formattedDate =
          '${now.year}/${_twoDigits(now.month)}/${_twoDigits(now.day)}';
      setState(() {
        _capturedImage = File(image.path);
        _imageDate = formattedDate;
      });
    } on Exception catch (e) {
      logger.e('cameraPage:$e');
    } finally {
      setState(() {
        _isTakingPicture = false; // 撮影完了後にフラグをリセット
      });
    }
  }

  String _twoDigits(int n) {
    return n.toString().padLeft(2, '0');
  }
}
