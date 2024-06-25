import 'dart:io';

import 'package:flutter/material.dart';

class ImageDetailPage extends StatelessWidget {
  const ImageDetailPage({super.key, required this.imagePath});

  static const String routeName = '/image_detail';
  static const String routePath = '/image_detail';

  final String imagePath;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Image Detail'),
      ),
      body: Center(
        child: Hero(
          tag: imagePath,
          child: Image.file(
            File(imagePath),
            fit: BoxFit.contain,
          ),
        ),
      ),
    );
  }
}
