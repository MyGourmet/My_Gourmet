import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/database/database.dart';
import 'home_repository.dart';

final homeControllerProvider = Provider<HomeController>((ref) {
  return HomeController(ref);
});

class HomeController {
  HomeController(this.ref);

  final Ref ref;

  HomeRepository get _homeRepository => ref.read(homeRepositoryProvider);

  Future<List<Photo>> getPhotos() async {
    try {
      final photos = await _homeRepository.getAllPhotos();
      return _removeInvalidPhotos(photos);
    } on Exception catch (e) {
      debugPrint('Error fetching photos: $e');
      return [];
    }
  }

  List<Photo> _removeInvalidPhotos(List<Photo> photos) {
    final validPhotos = <Photo>[];
    for (final photo in photos) {
      final file = File(photo.path);
      if (file.existsSync()) {
        validPhotos.add(photo);
      }
    }
    return validPhotos;
  }

  Future<List<Size>> calculateSizes(List<Photo> photos) async {
    final sizes = <Size>[];
    for (final photo in photos) {
      final file = File(photo.path);
      final decodedImage = await decodeImageFromList(await file.readAsBytes());
      final width = decodedImage.width.toDouble();
      final height = decodedImage.height.toDouble();
      if (width > height) {
        sizes.add(const Size(172, 172));
      } else {
        sizes.add(const Size(172, 228));
      }
    }
    return sizes;
  }

  Future<void> printPhotoPaths() async {
    try {
      final photos = await _homeRepository.getAllPhotos();
      for (final photo in photos) {
        debugPrint('Photo path: ${photo.path}');
      }
    } on Exception catch (e) {
      debugPrint('Error fetching photos: $e');
    }
  }
}
