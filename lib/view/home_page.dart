import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:my_gourmet/core/database/database.dart';

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
      _photos = getAppDatabaseInstance().getAllPhotos(); // 写真データを非同期で取得
    } catch (e) {
      print('写真データの取得に失敗しました: $e');
    }
  }

  Future<void> printPhotoPaths() async {
    try {
      final photos = await getAppDatabaseInstance().getAllPhotos();
      for (var photo in photos) {
        print('Photo path: ${photo.path}');
      }
    } catch (e) {
      print('Error fetching photos: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('保存された写真'),
      ),
      body: FutureBuilder<List<Photo>>(
        future: _photos,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('エラーが発生しました'));
          } else if (snapshot.hasData) {
            return GridView.builder(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
              ),
              itemCount: snapshot.data!.length,
              itemBuilder: (context, index) {
                Photo photo = snapshot.data![index];
                return Image.file(
                  File(photo.path),
                  fit: BoxFit.cover,
                );
              },
            );
          } else {
            return Center(child: Text('データがありません'));
          }
        },
      ),
    );
  }
}
