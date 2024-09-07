import 'dart:io';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:image_gallery_saver/image_gallery_saver.dart';
import 'package:permission_handler/permission_handler.dart';

import '../../../core/logger.dart';

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

// TODO(SHO): 状態管理方法を再検討（画面側のローカルステートを別ファイルから更新している部分を解消）
extension CameraControllerExtension on CameraController {
  Future<void> takePictureAndSave(
    BuildContext context,
    WidgetRef ref, // 追加
    ValueNotifier<File?> capturedImage,
    ValueNotifier<bool> isTakingPicture,
    ValueNotifier<String?> imageDate,
  ) async {
    isTakingPicture.value = true; // 撮影中フラグを設定

    try {
      // 写真を撮影
      final image = await takePicture();
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

      // 撮影した画像のファイルパスを記録
      final now = DateTime.now();
      final formattedDate =
          '${now.year}/${_twoDigits(now.month)}/${_twoDigits(now.day)}';
      capturedImage.value = File(image.path);
      imageDate.value = formattedDate;

      // 撮影した画像を用いて次の写真をロードする処理
      final photoListNotifier = ref.read(photoListProvider.notifier);

      // 撮影した写真をリストに反映
      await photoListNotifier.addPhotoToList(capturedImage.value!);
    } on Exception catch (e) {
      logger.e('cameraPage:$e');
    } finally {
      isTakingPicture.value = false; // 撮影完了後にフラグをリセット
    }

    // TODO(SHO): _PhotoListNotifierのloadNextメソッドを参考に、registerStoreInfoメソッドを呼び出す
    // 以下、詳細：
    // todo  photoId: 一意の値 && 出来ればスワイプ時と同様の形式だとベターで、以下が出来たら理想：
    // 写真ライブラリへの保存前に保存された後のidが事前取得出来る or 写真ライブラリへの保存後に該当写真のidを取得出来る
    // todo  userId: 問題なくなる予定（kimさんの対応後）
    //  todo latitude: EXIFから取得(写真ライブラリへの保存後かどうか検討）
    //  todo longitude: EXIFから取得(写真ライブラリへの保存後かどうか検討）
    // 参考： https://github.com/MyGourmet/My_Gourmet/commit/5b11e5077c978950d8a0a1201ba0b4de7e80c1cd#diff-ab1d426be481ef43dc5f9e0c87d8ddfd0b98cae9613338d11317bb41f95e2a97
  }

  String _twoDigits(int n) {
    return n.toString().padLeft(2, '0');
  }
}

/// 写真リストを管理するプロバイダー
final photoListProvider =
    AsyncNotifierProvider.autoDispose<_PhotoListNotifier, List<File>>(
  _PhotoListNotifier.new,
);

class _PhotoListNotifier extends AutoDisposeAsyncNotifier<List<File>> {
  /// 初期処理
  @override
  Future<List<File>> build() async {
    // 初期の状態として空のリストを返す
    return [];
  }

  /// 撮影した写真をリストに追加するメソッド
  Future<void> addPhotoToList(File newPhoto) async {
    final currentPhotos = state.valueOrNull ?? [];

    // 撮影した写真をリストに追加
    state = AsyncValue.data([...currentPhotos, newPhoto]);
  }
}
