import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:gap/gap.dart';

class CameraDetailPage extends ConsumerStatefulWidget {
  final File imageFile;
  final String imageDate;

  const CameraDetailPage({
    super.key,
    required this.imageFile,
    required this.imageDate,
  });

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
          padding: const EdgeInsets.fromLTRB(20.0, 0, 20.0, 28.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(20.0), // コンテナの内側のパディングを追加
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: Colors.black, // 枠線の色
                      width: 2.0, // 枠線の太さ
                    ),
                    borderRadius: BorderRadius.circular(16), // 枠線の角を丸くする
                  ),
                  child: Column(
                    children: [
                      Expanded(
                        child: Container(
                          decoration: BoxDecoration(
                            border: Border.all(
                              color: Colors.black, // 画像の枠線の色
                              width: 2.0, // 画像の枠線の太さ
                            ),
                            borderRadius: BorderRadius.circular(8), // 画像の角を丸くする
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(4), // 角を丸くする
                            child: Image.file(
                              widget.imageFile,
                              fit: BoxFit.cover, // 画像を枠に合わせて表示
                            ),
                          ),
                        ),
                      ),
                      const Gap(28), // 画像と日付の間にスペースを追加
                      Text(
                        widget.imageDate,
                        style:
                            const TextStyle(color: Colors.black, fontSize: 14),
                        textAlign: TextAlign.center, // 日付を中央揃えに設定
                      ),
                      const Gap(8), // 日付と---の間にスペースを追加
                      const Text(
                        '---',
                        style: TextStyle(color: Colors.black, fontSize: 14),
                        textAlign: TextAlign.center, // ---を中央揃えに設定
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
