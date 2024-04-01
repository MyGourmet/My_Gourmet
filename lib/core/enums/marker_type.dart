enum MarkerType {
  current(path: 'assets/images/current_position_marker.png'),
  ;

  const MarkerType({
    required this.path,
  });

  final String path;
}
