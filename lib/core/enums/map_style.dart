enum MapStyle {
  standard(url: 'mapbox://styles/mapbox/streets-v11'),
  light(url: 'mapbox://styles/mapbox/light-v11'),
  dark(url: 'mapbox://styles/mapbox/dark-v11');

  const MapStyle({required this.url});

  final String url;
}
