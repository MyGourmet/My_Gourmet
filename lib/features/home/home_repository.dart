import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/database/database.dart';

final homeRepositoryProvider = Provider<HomeRepository>((ref) {
  return HomeRepository();
});

class HomeRepository {
  Future<List<Photo>> getAllPhotos() async {
    return getAppDatabaseInstance().getAllPhotos();
  }
}
