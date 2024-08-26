import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';

class CameraDetailPage extends ConsumerStatefulWidget {
  const CameraDetailPage({
    super.key,
    required this.imageFile,
    required this.imageDate,
  });
  final File imageFile;
  final String imageDate;

  static const routeName = 'camera_detail_page';
  static const routePath = '/camera_detail_page';

  @override
  ConsumerState<CameraDetailPage> createState() => _CameraDetailPageState();
}

class _CameraDetailPageState extends ConsumerState<CameraDetailPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new),
          onPressed: () => context.pop(),
        ),
        foregroundColor: Colors.black,
      ),
      body: Center(
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
                            child: Image.file(
                              widget.imageFile,
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                      ),
                      const Gap(28),
                      Text(
                        widget.imageDate,
                        style:
                            const TextStyle(color: Colors.black, fontSize: 14),
                        textAlign: TextAlign.center,
                      ),
                      const Gap(8),
                      const Text(
                        '---',
                        style: TextStyle(color: Colors.black, fontSize: 14),
                        textAlign: TextAlign.center,
                      ),
                      const Gap(24),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
