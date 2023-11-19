class Photo extends Object {
  const Photo({
    required this.id,
    required this.createdAt,
    required this.updatedAt,
    required this.url,
    required this.userId,
    required this.otherUrls,
  });
  final String id;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String url;
  final String userId;
  final List<String> otherUrls;
}
