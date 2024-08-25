import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:camera/camera.dart';
import 'package:go_router/go_router.dart';

import 'camera_detail_page.dart';

class CameraPage extends ConsumerStatefulWidget {
  const CameraPage({super.key});

  static const routeName = 'camera_page';
  static const routePath = '/camera_page';

  @override
  ConsumerState<CameraPage> createState() => _CameraPageState();
}

class _CameraPageState extends ConsumerState<CameraPage> {
  File? _capturedImage; // 撮影した画像を格納する
  bool _isTakingPicture = false; // 撮影中かどうかを示すフラグ
  String? _imageDate; // 撮影日時を格納する

  @override
  Widget build(BuildContext context) {
    final cameraController = ref.watch(cameraControllerProvider);

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        backgroundColor: Colors.white, // 背景を白に設定
        appBar: AppBar(
          title: const Text(''),
          backgroundColor: Colors.white, // AppBarの背景も白に設定
          foregroundColor: Colors.black, // AppBarの文字色を黒に設定
        ),
        body: Stack(
          children: [
            Center(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20.0, 0, 20.0, 28.0),
                child: Column(
                  children: [
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.all(20.0),
                        decoration: BoxDecoration(
                          border: Border.all(
                            color: Colors.black, // 枠線の色
                            width: 2, // 枠線の太さ
                          ),
                          borderRadius: BorderRadius.circular(16), // 枠線の角を丸くする
                        ),
                        child: Column(
                          children: [
                            Expanded(
                              child: Container(
                                decoration: BoxDecoration(
                                  border: Border.all(
                                    color: Colors.black, // 枠線の色
                                    width: 2.0, // 枠線の太さ
                                  ),
                                  borderRadius:
                                      BorderRadius.circular(16), // 角を丸くする
                                ),
                                child: ClipRRect(
                                  borderRadius:
                                      BorderRadius.circular(16), // 角を丸くする
                                  child: cameraController.when(
                                    // 撮影プレビュー
                                    data: (data) => CameraPreview(data),
                                    error: (err, stack) => Center(
                                      child: Text('Error: $err'),
                                    ),
                                    // 読込中プログレス
                                    loading: () => const Center(
                                      child: CircularProgressIndicator(),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(height: 20), // プレビューとボタンの間にスペースを追加
                            cameraController.when(
                              data: (data) => GestureDetector(
                                onTap: _isTakingPicture
                                    ? null
                                    : () {
                                        onPressTakePictureButton(context, data);
                                      },
                                child: Container(
                                  width: 60, // 外側の円のサイズ
                                  height: 60,
                                  decoration: BoxDecoration(
                                    color: _isTakingPicture
                                        ? Colors.grey
                                        : Colors.white, // 撮影中は灰色に
                                    shape: BoxShape.circle, // 外側の円の形状
                                    border: Border.all(
                                      color: Colors.black, // 外側の円の境界線色
                                      width: 2.0, // 境界線の太さ
                                    ),
                                  ),
                                  child: Center(
                                    child: Container(
                                      width: 50, // 内側の円のサイズ
                                      height: 50,
                                      decoration: BoxDecoration(
                                        color: Colors.black, // 内側の円の色
                                        shape: BoxShape.circle, // 内側の円の形状
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              error: (err, stack) => Text('Error: $err'),
                              // 読込中は何も表示しない
                              loading: () => Container(),
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
                      color: Colors.white, // 背景色を白に設定
                      borderRadius: BorderRadius.circular(16), // 背景の角を丸くする
                      border: Border.all(
                        color: Colors.black, // 背景の枠線の色
                        width: 2.0, // 背景の枠線の太さ
                      ),
                    ),
                    padding: const EdgeInsets.all(8.0), // コンテナの内側のパディングを追加
                    child: Column(
                      crossAxisAlignment:
                          CrossAxisAlignment.center, // 日付を中央揃えに設定
                      children: [
                        Container(
                          decoration: BoxDecoration(
                            border: Border.all(
                              color: Colors.black, // 画像の枠線の色
                              width: 2.0, // 画像の枠線の太さ
                            ),
                            borderRadius: BorderRadius.circular(8), // 画像の角を丸くする
                          ),
                          width: MediaQuery.of(context).size.width /
                              5, // 画面の5分の1のサイズに縮小
                          height: MediaQuery.of(context).size.height /
                              5, // 高さも5分の1に縮小
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(4), // 角を丸くする
                            child: Image.file(
                              _capturedImage!,
                              fit: BoxFit.cover, // 画像を枠に合わせて表示
                            ),
                          ),
                        ),
                        const SizedBox(height: 4), // 画像と日付の間にスペースを追加
                        SizedBox(
                          width: MediaQuery.of(context).size.width /
                              5, // 画像の幅と同じに設定
                          child: Text(
                            _imageDate!,
                            style: TextStyle(color: Colors.black, fontSize: 12),
                            textAlign: TextAlign.center, // 日付を中央揃えに設定
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
    final _controller = CameraController(
      camera,
      ResolutionPreset.medium,
    );

    ref.onDispose(() {
      _controller.dispose();
    });

    await _controller.initialize();
    return _controller;
  });

  /// 写真撮影ボタン押下時処理
  Future<void> onPressTakePictureButton(
      BuildContext context, CameraController controller) async {
    setState(() {
      _isTakingPicture = true; // 撮影中フラグを設定
    });

    try {
      final image = await controller.takePicture();
      final DateTime now = DateTime.now();
      final String formattedDate =
          '${now.year}/${_twoDigits(now.month)}/${_twoDigits(now.day)}';
      setState(() {
        _capturedImage = File(image.path); // 撮影した画像を設定
        _imageDate = formattedDate; // 撮影した日時を設定
      });
    } catch (e) {
      // エラーハンドリング
      print("撮影中にエラーが発生しました: $e");
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
