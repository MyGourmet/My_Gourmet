import 'package:flutter/material.dart';
import 'package:gap/gap.dart';

import '../../../../core/build_context_extension.dart';
import '../../../../core/my_gourmet_card.dart';
import '../../../../core/themes.dart';
import '../../../../core/widgets/scalable_photo.dart';

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

    return MyGourmetCard(
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
              border: Border.all(
                color: Themes.gray[900]!,
                width: 2,
              ),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              children: [
                const Gap(4),
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: double.infinity,
                        height: MediaQuery.of(context).size.height * 0.5,
                        decoration: BoxDecoration(
                          border: Border.all(
                            color: Themes.gray[900]!,
                            width: 2,
                          ),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(16),
                          child: ScalablePhoto(
                            photoUrl: photoUrl,
                            height: MediaQuery.of(context).size.height * 0.5,
                          ),
                        ),
                      ),
                      Text(formattedDate, style: context.textTheme.titleSmall),
                      Text(
                        storeName,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: context.textTheme.titleMedium,
                      ),
                      if (showCardBack)
                        Divider(
                          color: Themes.gray[900],
                        ),
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
                  topRight: Radius.circular(16),
                ),
                border: Border.all(
                  color: Themes.gray[900]!,
                  width: 2,
                ),
                color: Themes.gray[100],
              ),
              child: const Icon(Icons.refresh),
            ),
        ],
      ),
    );
  }
}
