import 'package:flutter/material.dart';
import 'package:gap/gap.dart';

import '../../core/build_context_extension.dart';
import '../../core/themes.dart';
import '../widgets/scalableImage.dart';

class CardFront extends StatelessWidget {
  const CardFront({
    super.key,
    required this.imagePath,
    this.shopName,
    required this.dateTime,
    required this.address,
  });

  final String imagePath;
  final String? shopName;
  final DateTime dateTime;
  final String address;

  @override
  Widget build(BuildContext context) {
    final formattedDate = '${dateTime.year}/${dateTime.month}/${dateTime.day}';

    return Card(
      color: Colors.white,
      elevation: 5,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Stack(
        children: [
          Container(
            padding: const EdgeInsets.only(
              top: 48,
              bottom: 40,
              left: 16,
              right: 16,
            ),
            decoration: BoxDecoration(
              border: Border.all(),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Column(
              children: [
                const Gap(4),
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Hero(
                        tag: imagePath,
                        child: ScalableImage(
                          imagePath: imagePath,
                          height: MediaQuery.of(context).size.height * 0.5,
                        ),
                      ),
                      Text(formattedDate, style: context.textTheme.titleSmall),
                      Text(
                        shopName ?? '???',
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: context.textTheme.titleMedium,
                      ),
                      const Divider(),
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.pin_drop_outlined, size: 18),
                          const Gap(4),
                          Text(
                            address,
                            style: context.textTheme.bodySmall,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Positioned(
            top: 0,
            right: 0,
            child: Container(
              height: 36,
              width: 36,
              decoration: BoxDecoration(
                borderRadius: const BorderRadius.only(
                  topRight: Radius.circular(8),
                ),
                border: Border.all(),
                color: Themes.gray[100],
              ),
              child: const Icon(Icons.refresh),
            ),
          ),
        ],
      ),
    );
  }
}
