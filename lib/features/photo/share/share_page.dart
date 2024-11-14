import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:gap/gap.dart';

import '../../../../core/build_context_extension.dart';
import '../../../../core/my_gourmet_card.dart';
import '../../../../core/themes.dart';
import '../../../../core/widgets/scalable_photo.dart';

class SharePage extends HookConsumerWidget {
  const SharePage({
    super.key,
    // required photoUrl,
    // required storeName,
    // required dateTime,
    // required address,
  });

  // final String photoUrl;
  // final String storeName;
  // final DateTime dateTime;
  // final String address;

  static const String routeName = '/photo_share';
  static const String routePath = '/photo_share';

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
        toolbarHeight: 50, // AppBarの高さを50に設定
      ),
      body: SharePageCard(
        photoUrl:
            'https://msp.c.yimg.jp/images/v2/FUTi93tXq405grZVGgDqG_FIEsis4gX2HTFt1FMh8EAfM_kAs3ueD7RXBb2Vmpq6_DkHRjcqVvtxN5_NSrzgvj_MtPxbv5-u1Ovy7fPJ-XDUu_bJsMNdaHGmrhN2KRN9WN_Kxig3VG0BsaTOAz4R_5huyhPlzqSyIaTCY_18apemmQC4I-nnYj8PeDhNyTl470b0w0ESLkJrzMfu5MjzBQybAKZj5UFtNPoYPH0iPefYwu4zZET7ruKcv0CFVhnPzXmrQg712swHYm8aaivvmc34Q6mCE7p0UW8-sTINThs=/202109011621317719.jpg?errorImage=false',
        storeName: 'My Store',
        dateTime: DateTime.now(),
        address: '123 Main St',
      ),
    );
  }
}

class SharePageCard extends StatelessWidget {
  const SharePageCard({
    super.key,
    required this.photoUrl,
    required this.storeName,
    required this.dateTime,
    required this.address,
  });

  final String photoUrl;
  final String storeName;
  final DateTime dateTime;
  final String address;

  @override
  Widget build(BuildContext context) {
    final formattedDate = '${dateTime.year}/${dateTime.month}/${dateTime.day}';

    return Padding(
      padding: EdgeInsets.all(
        MediaQuery.sizeOf(context).width * 0.08,
      ),
      child: Container(
        color: Colors.orange, // 外側のオレンジ色の背景
        padding: EdgeInsets.all(
          MediaQuery.sizeOf(context).width * 0.08,
        ), // MyGourmetCardとの隙間を作るためのパディング
        child: MyGourmetCard(
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
                          Stack(
                            children: [
                              Container(
                                width: double.infinity,
                                height:
                                    MediaQuery.of(context).size.height * 0.5,
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
                                    height: MediaQuery.of(context).size.height *
                                        0.5,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          Text(formattedDate,
                              style: context.textTheme.titleSmall),
                          Text(
                            storeName,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: context.textTheme.titleMedium,
                          ),
                          ...[
                            Divider(color: Themes.gray[900]),
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
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
