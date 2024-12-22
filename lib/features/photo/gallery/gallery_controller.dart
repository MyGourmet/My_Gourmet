import 'dart:io';

import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:photo_manager/photo_manager.dart';

import '../../../core/database/database.dart' as local;
import '../../../core/local_photo_repository.dart';
import '../../../core/logger.dart';
import '../../auth/auth_controller.dart';
import '../../auth/authed_user.dart';
import '../photo.dart';
import '../photo_repository.dart';

final fetchPhotosFutureProvider =
    FutureProvider.autoDispose<List<Photo>>((ref) async {
  final userId = ref.watch(userIdProvider);
  // TODO(kim): ログイン前にこの処理が呼び出される状況になっているが、userIdがnullになりうる状態で呼び出される状況を回避する。
  if (userId == null) {
    return [];
  }

  await ref.watch(authedUserStreamProvider.future);
  final authedUserAsync = ref.watch(authedUserStreamProvider).valueOrNull;
  final isReadyForUse =
      authedUserAsync?.classifyPhotosStatus == ClassifyPhotosStatus.readyForUse;
  if (!isReadyForUse) {
    return <Photo>[];
  }

  final result =
      await ref.read(photoRepositoryProvider).downloadPhotos(userId: userId);

  return result.where((e) => e.url.isNotEmpty).toList();
});

final galleryControllerProvider = Provider<GalleryController>((ref) {
  return GalleryController(ref);
});

class GalleryController {
  GalleryController(this.ref);

  final Ref ref;

  LocalPhotoRepository get _localPhotoRepository =>
      ref.read(localPhotoRepositoryProvider);

  Future<List<local.Photo>> getPhotos() async {
    try {
      final photos = await _localPhotoRepository.getAllPhotos();
      return _removeInvalidPhotos(photos);
    } on Exception catch (e) {
      logger.e('Error fetching photos: $e');
      return [];
    }
  }

  Future<List<local.Photo>> _removeInvalidPhotos(
      List<local.Photo> photos,) async {
    final validPhotos = <local.Photo>[];
    for (final photo in photos) {
      final file = await getFileByPhoto(photo);
      if (file.existsSync()) {
        validPhotos.add(photo);
      }
    }
    return validPhotos;
  }

  Future<List<Size>> calculateSizes(List<local.Photo> photos) async {
    final sizes = <Size>[];
    for (final photo in photos) {
      if ((photo.width == 0 || photo.height == 0) ||
          (photo.width > photo.height)) {
        sizes.add(const Size(172, 172));
      } else {
        sizes.add(const Size(172, 228));
      }
    }
    return sizes;
  }

  Future<void> printPhotoPaths() async {
    try {
      await _localPhotoRepository.getAllPhotos();
    } on Exception catch (e) {
      logger.e('Error fetching photos: $e');
    }
  }

  Future<File> getFileByPhoto(local.Photo photo) async {
    if (Platform.isAndroid) {
      return File(photo.path);
    }

    final asset = await AssetEntity.fromId(photo.id);
    final file = await asset!.file;

    return file!;
  }
}
