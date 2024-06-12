import 'package:flutter/material.dart';

import '../core/themes.dart';
import 'image_detail/image_detail_card.dart';

class ImageDetailPage extends StatefulWidget {
  const ImageDetailPage({
    super.key,
    required this.heroImagePath,
    required this.photoPathList,
    required this.index,
  });

  static const String routeName = 'image_detail';
  static const String routePath = 'image_detail';

  final String heroImagePath;
  final List<String> photoPathList;
  final int index;

  @override
  State<ImageDetailPage> createState() => _ImageDetailPageState();
}

class _ImageDetailPageState extends State<ImageDetailPage> {
  int get index => widget.index;
  late final PageController _pageController;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: index, viewportFraction: 0.9);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Stack(
          children: [
            AppBar(),
            Positioned(
              bottom: 0,
              child: Container(
                padding: EdgeInsets.only(
                  top: MediaQuery.of(context).size.height * 0.3,
                ),
                width: MediaQuery.of(context).size.width,
                color: Themes.mainOrange[50],
              ),
            ),
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                itemCount: widget.photoPathList.length,
                itemBuilder: (context, index) {
                  return Padding(
                    padding: EdgeInsets.only(
                      top: MediaQuery.of(context).size.height * 0.1,
                      left: 4,
                      right: 4,
                    ),
                    child: ImageDetailCard(
                      index: index,
                      heroIndex: widget.index,
                      heroImagePath: widget.heroImagePath,
                      imagePath: widget.photoPathList[index],
                      shopName: 'Shop Name $index',
                      dateTime: DateTime.now(),
                      address: 'Yokohama, kanagawa JAPAN',
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
