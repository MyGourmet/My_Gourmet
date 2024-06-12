import 'package:flutter/material.dart';

class ScalableImage extends StatefulWidget {
  const ScalableImage({
    required this.imagePath,
    this.height,
    this.width,
    super.key,
  });

  final String imagePath;
  final double? height;
  final double? width;

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
            child: Image.asset(
              widget.imagePath,
              fit: BoxFit.cover,
            ),
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
                Image.asset(
                  widget.imagePath,
                  fit: BoxFit.cover,
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
