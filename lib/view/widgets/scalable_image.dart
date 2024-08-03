import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

// TODO(anyone): 全体的にImageをphotoの名称に変更
class ScalableImage extends StatefulWidget {
  const ScalableImage({
    // TODO(anyone): 不要になったタイミングで削除
    this.imageFile,
    this.photoUrl,
    this.height,
    this.width,
    super.key,
  }) : assert(imageFile != null || photoUrl != null);

  final File? imageFile;
  final double? height;
  final double? width;
  final String? photoUrl;

  // TODO(anyone): このメソッドは不要になったタイミングで削除
  Widget get photoWidget {
    if (imageFile != null) {
      return Image.file(
        imageFile!,
        fit: BoxFit.cover,
      );
    }
    return CachedNetworkImage(
      imageUrl: photoUrl!,
      fit: BoxFit.cover,
    );
  }

  @override
  State<ScalableImage> createState() => ScalableImageState();
}

class ScalableImageState extends State<ScalableImage> {
  void showImageDialog(Widget image) {
    showDialog<void>(
      context: context,
      builder: (_) {
        return AlertDialog(
          insetPadding: const EdgeInsets.all(8),
          content: image,
          contentPadding: EdgeInsets.zero,
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: SizedBox(
            height: widget.height,
            width: widget.width,
            child: widget.photoWidget,
          ),
        ),
        Positioned(
          left: 0,
          child: IconButton(
            icon: const Icon(Icons.zoom_out_map, size: 18),
            style: ElevatedButton.styleFrom(
              foregroundColor: Colors.white,
              backgroundColor: Colors.black.withOpacity(0.5),
              shape: const CircleBorder(),
            ),
            onPressed: () {
              showImageDialog(
                widget.photoWidget,
              );
            },
          ),
        ),
      ],
    );
  }
}
