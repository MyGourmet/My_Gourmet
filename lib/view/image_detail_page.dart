import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../core/themes.dart';
import 'image_detail/image_detail_card.dart';

class ImageDetailPage extends StatefulWidget {
  const ImageDetailPage({
    super.key,
    // TODO(anyone): 不要なタイミングで削除
    required this.index,
    // TODO(anyone): 不要なタイミングで削除
    required this.photoUrl,
  });

  static const String routeName = '/image_detail';
  static const String routePath = '/image_detail';

  final int index;
  final String photoUrl;

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
      appBar: AppBar(
        backgroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
      ),
      body: Center(
        child: Stack(
          children: [
            Positioned(
              bottom: 0,
              child: Container(
                // padding: EdgeInsets.only(
                //   top: MediaQuery.of(context).size.height * 0.3,
                // ),
                width: MediaQuery.of(context).size.width,
                color: Themes.mainOrange[50],
              ),
            ),
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                itemCount: 1,
                itemBuilder: (context, index) {
                  return Padding(
                    padding: EdgeInsets.only(
                      top: MediaQuery.of(context).size.height * 0.01,
                      bottom: MediaQuery.of(context).size.height * 0.01,
                      left: 4,
                      right: 4,
                    ),
                    child: ImageDetailCard(
                      index: index,
                      heroIndex: widget.index,
                      photoUrl: widget.photoUrl,
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
