import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:location/location.dart';
import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart';
import '../core/enums/map_style.dart';
import '../core/enums/marker_type.dart';
import '../features/auth/auth_controller.dart';
import '../features/photo/photo.dart';
import '../features/photo/photo_controller.dart';

/// マイページ
class MapPage extends ConsumerStatefulWidget {
  const MapPage({super.key});

  static const routePath = '/map_page';

  @override
  ConsumerState<MapPage> createState() => _MapPageState();
}

class _MapPageState extends ConsumerState<MapPage> {
  late MapboxMap _mapboxMap;
  late PointAnnotationManager _annotationManager;
  late LocationData _currentPosition;

  @override
  void initState() {
    super.initState();
    Future(() async {
      final location = Location();
      final permission = await location.hasPermission();
      if (permission == PermissionStatus.deniedForever) {
        await location.requestPermission();
      }
    });
  }

  // @override
  // void dispose() {
  //   _mapboxMap.dispose();
  //   super.dispose();
  // }

  @override
  Widget build(BuildContext context) {
    final userId = ref.watch(userIdProvider);

    return SafeArea(
      child: Scaffold(
        body: MapWidget(
          styleUri: MapStyle.standard.url,
          cameraOptions: CameraOptions(
            center: Point(
              coordinates: Position(
                139.7586677640881,
                35.67369269880291,
              ),
            ).toJson(),
            zoom: 10,
          ),
          onMapCreated: (controller) async {
            _mapboxMap = controller;

            _currentPosition = await Location().getLocation();

            // create annotation manager
            _annotationManager = await _mapboxMap.annotations.createPointAnnotationManager();

            // create current pin
            await _createCurrentPin();

            // move camera to current position
            await _easeToCurrentPosition();

            // add photo markers
            await _addPhotoMarkers(
              photos: await ref.read(photoControllerProvider).downloadPhotos(
                    category: 'photo',
                    userId: userId,
                    useMock: true,
                  ),
            );
          },
        ),
        floatingActionButton: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // zoom in
                FloatingActionButton.small(
                  onPressed: _zoomIn,
                  child: const Icon(Icons.add),
                ),
                const Gap(5),
                // zoom out
                FloatingActionButton.small(
                  onPressed: _zoomOut,
                  child: const Icon(Icons.remove),
                ),
              ],
            ),
            FloatingActionButton(
              onPressed: _easeToCurrentPosition,
              child: const Icon(Icons.my_location),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _createCurrentPin() async {
    final bytes = await rootBundle.load(MarkerType.current.path);
    final list = bytes.buffer.asUint8List();

    await _annotationManager.create(
      PointAnnotationOptions(
        geometry: Point(
          coordinates: Position(
            _currentPosition.longitude!,
            _currentPosition.latitude!,
          ),
        ).toJson(),
        iconSize: 1,
        iconOffset: [0.0, -5.0],
        symbolSortKey: 10,
        image: list,
      ),
    );
  }

  Future<void> _addPhotoMarkers({
    required List<Photo> photos,
  }) async {
    final options = <PointAnnotationOptions>[];
    for (final photo in photos) {
      if (photo.addressInfo == null) continue;
      options.add(
        await _convertPhotoToPointAnnotationOptions(
          photo: photo,
        ),
      );
    }
    await _annotationManager.createMulti(options);
  }

  Future<void> _easeToCurrentPosition() async {
    await _mapboxMap.easeTo(
      CameraOptions(
        center: Point(
          coordinates: Position(
            _currentPosition.longitude!,
            _currentPosition.latitude!,
          ),
        ).toJson(),
      ),
      MapAnimationOptions(
        duration: 500,
      ),
    );
  }

  // zoom in
  Future<void> _zoomIn() async {
    final cs = await _mapboxMap.getCameraState();
    final co = CameraOptions(
      center: cs.center,
      zoom: cs.zoom + 1,
      bearing: cs.bearing,
    );
    await _mapboxMap.easeTo(
      co,
      MapAnimationOptions(duration: 200, startDelay: 0),
    );
  }

  // zoom out
  Future<void> _zoomOut() async {
    final cs = await _mapboxMap.getCameraState();
    final co = CameraOptions(
      center: cs.center,
      zoom: cs.zoom - 1,
      bearing: cs.bearing,
    );
    await _mapboxMap.easeTo(
      co,
      MapAnimationOptions(duration: 200, startDelay: 0),
    );
  }

  Future<Uint8List> _convertUrlToUint8List(String url) async {
    final bytes = await NetworkAssetBundle(Uri.parse(url)).load(url);
    return bytes.buffer.asUint8List();
  }

  Future<PointAnnotationOptions> _convertPhotoToPointAnnotationOptions({
    required Photo photo,
  }) async {
    final list = await _convertUrlToUint8List(photo.url);

    return PointAnnotationOptions(
      // geometry: photo.addressInfo!.toPoint,
      geometry: Point(
        coordinates: Position(
          photo.addressInfo!.longitude,
          photo.addressInfo!.latitude,
        ),
      ).toJson(),
      iconSize: 0.35,
      iconOffset: [0.0, -5.0],
      symbolSortKey: 10,
      image: list,
    );
  }
}
