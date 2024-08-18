import 'package:flutter/material.dart';

import '../core/my_gourmet_card.dart';
import '../core/themes.dart';

class ImageCarousel extends StatefulWidget {
  const ImageCarousel({super.key});

  @override
  State<ImageCarousel> createState() => _ImageCarouselState();
}

class _ImageCarouselState extends State<ImageCarousel> {
  final PageController _pageController = PageController(viewportFraction: 0.9);

  final List<String> _images = [
    'assets/images/image1.jpeg',
    'assets/images/image2.jpeg',
    'assets/images/image3.png',
  ];

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
    return Scaffold(
      appBar: AppBar(),
      body: Stack(
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
          Center(
            child: PageView.builder(
              controller: _pageController,
              itemCount: _images.length,
              itemBuilder: (context, index) {
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  child: MyGourmetCard(
                    child: Container(
                      padding: const EdgeInsets.only(
                        top: 24,
                        bottom: 40,
                        left: 16,
                        right: 16,
                      ),
                      decoration: BoxDecoration(
                        border: Border.all(),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Column(
                        children: [
                          Stack(
                            children: [
                              ClipRRect(
                                borderRadius: BorderRadius.circular(8),
                                child: SizedBox(
                                  height:
                                      MediaQuery.of(context).size.height * 0.5,
                                  child: Image.asset(
                                    _images[index],
                                    fit: BoxFit.cover,
                                  ),
                                ),
                              ),
                              Positioned(
                                left: 0,
                                child: IconButton(
                                  icon:
                                      const Icon(Icons.zoom_out_map, size: 18),
                                  style: ElevatedButton.styleFrom(
                                    foregroundColor: Colors.white,
                                    backgroundColor:
                                        Colors.black.withOpacity(0.5),
                                    shape: const CircleBorder(),
                                  ),
                                  onPressed: () {
                                    showImageDialog(
                                      Image.asset(
                                        _images[index],
                                        fit: BoxFit.cover,
                                      ),
                                    );
                                  },
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
