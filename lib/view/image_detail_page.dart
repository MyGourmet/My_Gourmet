import 'package:flutter/material.dart';

import '../core/themes.dart';
import 'image_detail/image_detail_card.dart';

class ImageDetailPage extends StatefulWidget {
  const ImageDetailPage({super.key});

  static const String routeName = 'image_detail';
  static const String routePath = 'image_detail';

  @override
  State<ImageDetailPage> createState() => _ImageDetailPageState();
}

class _ImageDetailPageState extends State<ImageDetailPage> {
  final PageController _pageController = PageController(viewportFraction: 0.9);

  final List<String> _images = [
    'assets/images/image1.jpeg',
    'assets/images/image2.jpeg',
    'assets/images/image3.png',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Stack(
          children: [
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
                itemCount: _images.length,
                itemBuilder: (context, index) {
                  return Padding(
                    padding: EdgeInsets.only(
                      top: MediaQuery.of(context).size.height * 0.1,
                      right: 4,
                      left: 4,
                    ),
                    child: ImageDetailCard(
                      imagePath: _images[index],
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
