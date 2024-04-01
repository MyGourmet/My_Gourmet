import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart';

extension GeoPointExtension on GeoPoint {
  Map<String, dynamic>? get toPoint => Point(
        coordinates: Position(
          longitude,
          latitude,
        ),
      ).toJson();
}
