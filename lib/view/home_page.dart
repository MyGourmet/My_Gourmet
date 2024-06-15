import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:go_router/go_router.dart';

import '../core/database/database.dart';
import '../features/home/home_controller.dart';

class HomePage extends ConsumerStatefulWidget {
  const HomePage({super.key});

  static const routeName = 'home_page';
  static const routePath = '/home_page';

  @override
  ConsumerState<HomePage> createState() => _HomePageState();
}

class _HomePageState extends ConsumerState<HomePage> {
  late Future<List<Photo>> _photos;
  late Future<List<Size>> _sizes;

  @override
  void initState() {
    super.initState();
    _photos = ref.read(homeControllerProvider).getPhotos();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: FutureBuilder<List<Photo>>(
          future: _photos,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            } else if (snapshot.hasError) {
              return const Center(child: Text('エラーが発生しました'));
            } else if (snapshot.hasData) {
              _sizes = ref
                  .read(homeControllerProvider)
                  .calculateSizes(snapshot.data!);
              return FutureBuilder<List<Size>>(
                future: _sizes,
                builder: (context, sizeSnapshot) {
                  if (sizeSnapshot.connectionState == ConnectionState.waiting) {
                    return const CircularProgressIndicator();
                  } else if (sizeSnapshot.hasError) {
                    return const Center(child: Text('エラーが発生しました'));
                  } else if (sizeSnapshot.hasData) {
                    if (snapshot.data!.isEmpty) {
                      return Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Image.asset(
                              'assets/images/no_photo.png',
                              width: 200,
                            ),
                            const SizedBox(height: 16),
                            Text(
                              '保存された写真がまだありません...',
                              style: Theme.of(context).textTheme.titleSmall,
                            ),
                          ],
                        ),
                      );
                    }
                    return MasonryGridView.count(
                      crossAxisCount: 2,
                      mainAxisSpacing: 8,
                      crossAxisSpacing: 8,
                      itemBuilder: (context, index) {
                        final photo = snapshot.data![index];
                        final size = sizeSnapshot.data![index];

                        return FutureBuilder<File>(
                          future: ref
                              .read(homeControllerProvider)
                              .getFileByPhoto(photo),
                          builder: (context, snapshot) {
                            if (sizeSnapshot.hasError) {
                              return const Center(child: Text('エラーが発生しました'));
                            }
                            if (snapshot.data == null) {
                              return const CircularProgressIndicator();
                            }

                            return Hero(
                              tag: photo.path,
                              child: GestureDetector(
                                onTap: () {
                                  context.push(
                                    '/home_page/image_detail',
                                    extra: {
                                      'imageFile': File(photo.path),
                                      'photoFileList': snapshot.data!,
                                      'index': index,
                                    },
                                  );
                                },
                                child: Container(
                                  width: size.width,
                                  height: size.height,
                                  decoration: BoxDecoration(
                                    border: Border.all(
                                      color: Colors.grey,
                                      width: 2,
                                    ),
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(14),
                                    child: Image.file(
                                      snapshot.data!,
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                ),
                              ),
                            );
                          },
                        );
                      },
                      itemCount: snapshot.data!.length,
                    );
                  } else {
                    return Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Image.asset(
                          'assets/images/no_photo.png',
                          width: 200,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          '保存された写真がまだありません...',
                          style: Theme.of(context).textTheme.titleSmall,
                        ),
                      ],
                    );
                  }
                },
              );
            } else {
              return Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Image.asset(
                    'assets/images/no_photo.png',
                    width: 200,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    '保存された写真がまだありません...',
                    style: Theme.of(context).textTheme.titleSmall,
                  ),
                ],
              );
            }
          },
        ),
      ),
    );
  }
}
