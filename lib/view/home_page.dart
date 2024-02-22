import 'dart:math' as math;

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../features/auth/auth_controller.dart';
import '../features/auth/authed_user.dart';
import '../features/photo/photo_controller.dart';
import 'onboarding_page.dart';

// TODO(masaki): Themeやconstの管理

// TODO(masaki): ストリーム管理&オンボーディングの実装後にbuildSecondPage()など画面描画を全体的に見直す
class HomePage extends ConsumerStatefulWidget {
  const HomePage({super.key});

  static const routePath = '/home_page';

  @override
  ConsumerState<HomePage> createState() => _HomePageState();
}

class _HomePageState extends ConsumerState<HomePage> {
  late PageController _pageController;
  bool _isContainerVisible = true;
  bool isLoading = false;
  final List<String> imagePaths = [
    'assets/images/image1.jpeg',
    'assets/images/image2.jpeg',
    'assets/images/image3.jpeg',
    'assets/images/image4.png',
    'assets/images/image5.jpeg',
    'assets/images/image6.jpeg',
    'assets/images/image7.jpeg',
    'assets/images/image8.jpeg',
    'assets/images/image9.jpeg',
    'assets/images/image10.jpeg',
    'assets/images/image11.jpeg',
    'assets/images/image12.jpeg',
    'assets/images/image13.jpeg',
    'assets/images/image14.jpeg',
    'assets/images/image15.jpeg',
    'assets/images/image16.jpeg',
    'assets/images/image17.jpeg',
    'assets/images/image18.jpeg',
  ];

  @override
  void initState() {
    super.initState();
    _pageController = PageController(); // 初期化
  }

  @override
  void dispose() {
    _pageController.dispose(); // リソースの解放
    super.dispose();
  }

  Future<void> _onButtonPressed() async {
    setState(() {
      isLoading = true;
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    });

    try {
      await ref
          .read(photoControllerProvider)
          .uploadPhotos(userId: ref.watch(userIdProvider));
    } on Exception catch (e) {
      // 例外が発生した場合、エラーメッセージを表示
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString())),
        );
      }
    } finally {
      setState(() {
        isLoading = false; // 非同期処理が完了したら、isLoadingをfalseに設定
      });
    }
  }

  List<String>? photoUrls; // Firebaseからダウンロードした写真のURLを保持

  Future<void> _downloadPhotos(String category, WidgetRef ref) async {
    // TODO(masaki): 現状userIdがnull状態になり得るので、サインインするまでボタンを押せないようにする
    final result = await ref.read(photoControllerProvider).downloadPhotos(
          category: category,
          userId: ref.watch(
            userIdProvider,
          ),
        );

    setState(() {
      photoUrls = result.map((e) => e.url).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Scaffold(
          // TODO(masaki): ログアウト機能実装後 or 不要になったタイミングで削除
          floatingActionButton: Visibility(
            visible: _isContainerVisible,
            child: FloatingActionButton(
              onPressed: () {
                FirebaseAuth.instance.signOut();
              },
              child: const Icon(
                Icons.logout,
                color: Colors.black,
                size: 40,
              ),
            ),
          ),
          body: SafeArea(
            child: Stack(
              children: [
                Container(
                  height: MediaQuery.of(context).size.height,
                  width: MediaQuery.of(context).size.width,
                  color: Colors.black,
                  child: Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(16),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            _CategoryButton(
                              label: 'ラーメン',
                              onPressed: () => _downloadPhotos('ramen', ref),
                            ),
                            _CategoryButton(
                              label: 'カフェ',
                              onPressed: () => _downloadPhotos('cafe', ref),
                            ),
                            _CategoryButton(
                              label: '和食',
                              onPressed: () =>
                                  _downloadPhotos('japanese_food', ref),
                            ),
                            _CategoryButton(
                              label: 'その他',
                              onPressed: () => _downloadPhotos(
                                'international_cuisine',
                                ref,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Expanded(
                        child: GridView.builder(
                          gridDelegate:
                              const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 3, // 3列
                          ),
                          itemCount: photoUrls?.length ??
                              imagePaths
                                  .length, // imageUrlsがnullならimagePathsの長さを使用
                          itemBuilder: (context, index) {
                            return Image(
                              image: photoUrls != null
                                  ? NetworkImage(photoUrls![index])
                                  : AssetImage(imagePaths[index])
                                      as ImageProvider<Object>,
                              fit: BoxFit.cover,
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),
                Visibility(
                  visible: _isContainerVisible,
                  child: Positioned(
                    top: (MediaQuery.of(context).size.height - 327) /
                        2, // 縦方向中央に配置
                    left: (MediaQuery.of(context).size.width - 317) /
                        2, // 横方向中央に配置
                    child: Container(
                      width: 317, // 長方形の枠の幅を317に設定
                      height: 327, // 長方形の枠の高さを327に設定
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.88),
                        borderRadius: BorderRadius.circular(30), // 角を丸くする
                      ),
                      child: PageView(
                        controller: _pageController,
                        children: [
                          _buildFirstPage(),
                          _buildSecondPage(),
                        ],
                      ),
                    ),
                  ),
                ),
                // SizedBox(height: 30),
                _MyRotatingButton(
                  onVisibilityChanged: (isVisible) {
                    setState(() {
                      _isContainerVisible = isVisible; // コンテナの表示状態を更新
                    });
                  },
                ),
              ],
            ),
          ),
        ),
        // オンボーディングを上に重ねて表示
        if (!ref.watch(isOnBoardingCompletedProvider)) const OnboardingPage(),
      ],
    );
  }

  Widget _buildFirstPage() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const SizedBox(
          width: 250, // テキストの枠の幅を250に設定
          child: Center(
            child: Text(
              '以下のボタンを押すと、Google Photoの画像から\n料理の画像のみを判別して\nダウンロードできます！',
              textAlign: TextAlign.left,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
        const SizedBox(height: 30), // テキストとボタンの間のスペース
        ElevatedButton(
          onPressed: _onButtonPressed,
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFFEF913A), // ボタンの背景色を設定
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(30), // 角を丸くする
            ),
            minimumSize: const Size(250, 50),
          ),
          child: const Text(
            '画像を読み込む  1/2',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSecondPage() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        SizedBox(
          width: 250,
          child: Center(
            child: isLoading
                ? const Text(
                    // ignore: lines_longer_than_80_chars
                    '画像を処理中です...\n10分ほどお待ちください。\n他のアプリに切り替えても大丈夫です。\n完了すると通知でお知らせします',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  )
                : ref.watch(authedUserStreamProvider).when(
                      data: (authedUser) {
                        final status = authedUser.classifyPhotosStatus;
                        if (status == ClassifyPhotosStatus.readyForUse) {
                          return const Text(
                            '処理が完了しました！\n下記から画像をダウンロードできます！',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          );
                        } else if (status == ClassifyPhotosStatus.processing) {
                          return const Text(
                            // ignore: lines_longer_than_80_chars
                            '画像を処理中です...\n10分ほどお待ちください。\n他のアプリに切り替えても大丈夫です。\n完了すると通知でお知らせします',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          );
                        } else {
                          // TODO(masaki): エラーハンドリング
                          return Text(
                            status.name,
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          );
                        }
                      },
                      error: (_, __) => const Text(
                        '未確認',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      loading: () => const CircularProgressIndicator(),
                    ),
          ),
        ),
        const SizedBox(height: 30), // スペースを設定
        ElevatedButton(
          onPressed: () {
            _downloadPhotos('ramen', ref);
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFFEF913A), // ボタンの背景色を設定
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(30), // 角を丸くする
            ),
            minimumSize: const Size(250, 50),
          ),
          child: const Text(
            // MEMO(masaki): ステップの2/2というのを伝わりやすいUIに改修
            'ダウンロード 2/2',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
        ),
      ],
    );
  }
}

class _CategoryButton extends StatelessWidget {
  const _CategoryButton({required this.label, required this.onPressed});

  final String label;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPressed, // タップされたときに onPressed を呼び出す
      child: Container(
        decoration: BoxDecoration(
          color: const Color(0xFFD9D9D9),
          borderRadius: BorderRadius.circular(15), // 角を丸くする
        ),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Text(
          label,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
      ),
    );
  }
}

class _MyRotatingButton extends StatefulWidget {
  // コンテナの表示状態を通知するためのコールバック

  const _MyRotatingButton({required this.onVisibilityChanged});

  final ValueChanged<bool> onVisibilityChanged;

  @override
  _MyRotatingButtonState createState() => _MyRotatingButtonState();
}

class _MyRotatingButtonState extends State<_MyRotatingButton> {
  bool _isRotated = false;
  bool _isContainerVisible = true; // 新しく追加したフラグ

  void _toggleRotation() {
    setState(() {
      _isRotated = !_isRotated;
      _isContainerVisible = !_isContainerVisible; // タップする度にコンテナの表示状態を切り替える
      widget.onVisibilityChanged(_isContainerVisible); // コンテナの表示状態を外部に通知
    });
  }

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: (MediaQuery.of(context).size.height - 327) / 2 + 405,
      left: (MediaQuery.of(context).size.width - 60) / 2,
      child: Container(
        width: 60,
        height: 60,
        decoration: const BoxDecoration(
          color: Colors.black,
          shape: BoxShape.circle,
        ),
        child: InkWell(
          onTap: _toggleRotation, // タップ時に回転を切り替える
          child: Center(
            child: Transform.rotate(
              angle: _isRotated ? 0 : 45 * (math.pi / 180), // フラグに基づいて角度を決定
              child: const Icon(
                Icons.add,
                color: Color(0xFFEF913A),
                size: 40,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
