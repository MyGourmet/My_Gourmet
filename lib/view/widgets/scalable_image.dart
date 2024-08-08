import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

// TODO(anyone): 全体的にImageをphotoの名称に変更
class ScalableImage extends StatefulWidget {
  const ScalableImage({
    required this.photoUrl,
    this.height,
    this.width,
    this.zoomButtonSize,
    super.key,
  });

  final double? height;
  final double? width;
  final double? zoomButtonSize;
  final String photoUrl;

  Widget get photoWidget {
    return CachedNetworkImage(
      imageUrl: photoUrl,
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
          child: Container(
            height: widget.zoomButtonSize ?? 48,
            width: widget.zoomButtonSize ?? 48,
            padding: const EdgeInsets.all(4),
            child: IconButton(
              padding: EdgeInsets.zero,
              icon: const Icon(Icons.zoom_out_map, size: 16),
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
        ),
      ],
    );
  }
}
