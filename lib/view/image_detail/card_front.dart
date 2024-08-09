import 'package:flutter/material.dart';
import 'package:gap/gap.dart';

import '../../core/build_context_extension.dart';
import '../../core/themes.dart';
import '../widgets/scalable_image.dart';

class CardFront extends StatelessWidget {
  const CardFront({
    super.key,
    required this.photoUrl,
    required this.storeName,
    required this.dateTime,
    required this.address,
    required this.showCardBack,
  });

  final String photoUrl;
  final String storeName;
  final DateTime dateTime;
  final String address;
  final bool showCardBack;

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
        alignment: AlignmentDirectional.topEnd,
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
                      ScalableImage(
                        photoUrl: photoUrl,
                        height: MediaQuery.of(context).size.height * 0.5,
                      ),
                      Text(formattedDate, style: context.textTheme.titleSmall),
                      Text(
                        storeName,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: context.textTheme.titleMedium,
                      ),
                      if (showCardBack) const Divider(),
                      if (showCardBack)
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.pin_drop_outlined, size: 18),
                            const Gap(4),
                            Expanded(
                              child: Text(
                                address,
                                style: context.textTheme.bodySmall,
                                softWrap: true,
                              ),
                            ),
                          ],
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          if (showCardBack)
            Container(
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
        ],
      ),
    );
  }
}
