import 'package:hooks_riverpod/hooks_riverpod.dart';

final photoDetailControllerProvider =
    NotifierProvider<PhotoDetailController, bool>(() {
  return PhotoDetailController();
});

class PhotoDetailController extends Notifier<bool> {
  @override
  bool build() {
    return false;
  }

  /// 編集モードを切り替える
  void toggleEditing() {
    state = !state;
  }
}
