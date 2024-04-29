import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/database/database.dart';

class HomePage extends ConsumerStatefulWidget {
  const HomePage({super.key});

  static const routeName = 'home_page';
  static const routePath = '/home_page';

  @override
  ConsumerState<HomePage> createState() => _HomePageState();
}

class _HomePageState extends ConsumerState<HomePage> {
  late Future<List<Photo>> _photos;

  @override
  void initState() {
    super.initState();
    initializePhotos();
    printPhotoPaths();
  }

  Future<void> initializePhotos() async {
    try {
      _photos = getAppDatabaseInstance().getAllPhotos();
    } on Exception catch (e) {
      debugPrint('写真データの取得に失敗しました: $e');
    }
  }

  Future<void> printPhotoPaths() async {
    try {
      final photos = await getAppDatabaseInstance().getAllPhotos();
      for (final photo in photos) {
        debugPrint('Photo path: ${photo.path}');
      }
    } on Exception catch (e) {
      debugPrint('Error fetching photos: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('保存された写真'),
      ),
      body: FutureBuilder<List<Photo>>(
        future: _photos,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return const Center(child: Text('エラーが発生しました'));
          } else if (snapshot.hasData) {
            return GridView.builder(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
              ),
              itemCount: snapshot.data!.length,
              itemBuilder: (context, index) {
                final photo = snapshot.data![index];
                return Image.file(
                  File(photo.path),
                  fit: BoxFit.cover,
                );
              },
            );
          } else {
            return const Center(child: Text('データがありません'));
          }
        },
      ),
    );
  }
}
