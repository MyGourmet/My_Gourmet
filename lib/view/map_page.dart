import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart';

/// マイページ
class MapPage extends ConsumerWidget {
  const MapPage({super.key});

  static const routePath = '/map_page';

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      // ログインのリスト部分の設定
      body: Container(
        padding: const EdgeInsets.only(top: 50),
        child: MapWidget(),
      ),
    );
  }
}
