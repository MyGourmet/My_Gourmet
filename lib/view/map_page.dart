import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:geolocator/geolocator.dart';
import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart' as mapbox;
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
  late mapbox.MapboxMap _mapboxMap;
  late mapbox.PointAnnotationManager _annotationManager;
  late Position _currentPosition;

  @override
  void initState() {
    super.initState();
    Future(() async {
      final permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        await Geolocator.requestPermission();
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
        body: mapbox.MapWidget(
          styleUri: MapStyle.standard.url,
          cameraOptions: mapbox.CameraOptions(
            center: mapbox.Point(
              coordinates: mapbox.Position(
                139.7586677640881,
                35.67369269880291,
              ),
            ).toJson(),
            zoom: 10,
          ),
          onMapCreated: (controller) async {
            _mapboxMap = controller;

            _currentPosition = await Geolocator.getCurrentPosition(
              desiredAccuracy: LocationAccuracy.high,
            );

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
      mapbox.PointAnnotationOptions(
        geometry: mapbox.Point(
          coordinates: mapbox.Position(
            _currentPosition.longitude,
            _currentPosition.latitude,
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
    final options = <mapbox.PointAnnotationOptions>[];
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
      mapbox.CameraOptions(
        center: mapbox.Point(
          coordinates: mapbox.Position(
            _currentPosition.longitude,
            _currentPosition.latitude,
          ),
        ).toJson(),
      ),
      mapbox.MapAnimationOptions(
        duration: 500,
      ),
    );
  }

  // zoom in
  Future<void> _zoomIn() async {
    final cs = await _mapboxMap.getCameraState();
    final co = mapbox.CameraOptions(
      center: cs.center,
      zoom: cs.zoom + 1,
      bearing: cs.bearing,
    );
    await _mapboxMap.easeTo(
      co,
      mapbox.MapAnimationOptions(duration: 200, startDelay: 0),
    );
  }

  // zoom out
  Future<void> _zoomOut() async {
    final cs = await _mapboxMap.getCameraState();
    final co = mapbox.CameraOptions(
      center: cs.center,
      zoom: cs.zoom - 1,
      bearing: cs.bearing,
    );
    await _mapboxMap.easeTo(
      co,
      mapbox.MapAnimationOptions(duration: 200, startDelay: 0),
    );
  }

  Future<Uint8List> _convertUrlToUint8List(String url) async {
    final bytes = await NetworkAssetBundle(Uri.parse(url)).load(url);
    return bytes.buffer.asUint8List();
  }

  Future<mapbox.PointAnnotationOptions> _convertPhotoToPointAnnotationOptions({
    required Photo photo,
  }) async {
    final list = await _convertUrlToUint8List(photo.url);

    return mapbox.PointAnnotationOptions(
      // geometry: photo.addressInfo!.toPoint,
      geometry: mapbox.Point(
        coordinates: mapbox.Position(
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
