import 'dart:math' as math;

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
          body: SafeArea(
            child: Stack(
              children: [
                Container(
                  height: MediaQuery.of(context).size.height,
                  width: MediaQuery.of(context).size.width,
                  color: Colors.black,
                  child: Column(
                    children: [
                      Expanded(
                        child: GridView.builder(
                          gridDelegate:
                              const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2, // 3列
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
                        4, // 縦方向中央に配置
                    left: (MediaQuery.of(context).size.width - 317) /
                        2, // 横方向中央に配置
                    child: Container(
                      width: 317, // 長方形の枠の幅を317に設定
                      height: 457, // 長方形の枠の高さを327に設定
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
          child: Padding(
            padding: EdgeInsets.only(top: 5),
            child: Center(
              child: Text(
                'あなたのGoogle Photosから自動で食べ物の写真を読み込みます。',
                textAlign: TextAlign.left,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ),
        const SizedBox(
          width: 250, // テキストの枠の幅を250に設定
          child: Padding(
            padding: EdgeInsets.only(top: 5),
            child: Center(
              child: Text(
                '読み込まれた画像は順次ホーム画面に表示されます。',
                textAlign: TextAlign.left,
                style: TextStyle(
                  fontSize: 16,
                ),
              ),
            ),
          ),
        ),
        const SizedBox(
          width: 260, // テキストの枠の幅を250に設定
          child: Padding(
            padding: EdgeInsets.only(top: 30),
            child: Row(
              children: <Widget>[
                SizedBox(
                  width: 50, // テキストの枠の幅を250に設定
                  child: Padding(
                    padding: EdgeInsets.only(top: 5),
                    child: Center(
                      child: Text(
                        '注意点',
                        textAlign: TextAlign.left,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFFEF913A),
                        ),
                      ),
                    ),
                  ),
                ),
                SizedBox(
                  width: 150, // テキストの枠の幅を250に設定
                  child: Padding(
                    padding: EdgeInsets.only(top: 5),
                    child: Center(
                      child: Text(
                        '必ずご確認ください',
                        textAlign: TextAlign.left,
                        style: TextStyle(
                          fontSize: 12,
                          color: Color(0xFFEF913A),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        SizedBox(
          width: 265, // テキストの枠の幅を250に設定
          child: Padding(
            padding: const EdgeInsets.only(top: 5),
            child: Card(
              color: const Color(0xFFFFE8DB),
              shape: RoundedRectangleBorder(
                side: const BorderSide(
                  color: Color(0xFFEF913A), //色
                  width: 2, //太さ
                ),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Padding(
                padding: EdgeInsets.all(8),
                child: Text(
                  '※ 3分程、時間がかかります。'
                  '\n※ 読み込み中はアプリをバックグラウンドに残してください。'
                  '完全に閉じないでください。(他のアプリを使用しても問題ありません。)',
                  textAlign: TextAlign.left,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
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
            '画像読み込みを開始する',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.white,
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
                    '画像を読み込み中です...',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  )
                : ref.watch(authedUserStreamProvider).when(
                      data: (authedUser) {
                        final status = authedUser.classifyPhotosStatus;
                        if (status == ClassifyPhotosStatus.readyForUse) {
                          return const Text(
                            '初期表示用の画像の読み込みが完了しました。\n下記ボタンから、画像をダウンロードしてください。',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          );
                        } else if (status == ClassifyPhotosStatus.processing) {
                          return const Text(
                            // ignore: lines_longer_than_80_chars
                            '画像を処理中です...\n3分ほどお待ちください。\n他のアプリに切り替えても大丈夫です。\n完了すると通知でお知らせします',
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
            'ダウンロードする',
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

class _MyRotatingButton extends StatefulWidget {
  // コンテナの表示状態を通知するためのコールバック

  const _MyRotatingButton({required this.onVisibilityChanged});

  final ValueChanged<bool> onVisibilityChanged;

  @override
  _MyRotatingButtonState createState() => _MyRotatingButtonState();
}

class _MyRotatingButtonState extends State<_MyRotatingButton> {
  bool _isRotated = false;
  bool _isContainerVisible = false; // 新しく追加したフラグ

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
      top: (MediaQuery.of(context).size.height - 327) / 2 + 442,
      left: MediaQuery.of(context).size.width - 75,
      child: Container(
        width: 60,
        height: 60,
        decoration: const BoxDecoration(
          color: Color(0xFFEF913A),
          shape: BoxShape.circle,
        ),
        child: InkWell(
          onTap: _toggleRotation, // タップ時に回転を切り替える
          child: Center(
            child: Transform.rotate(
              angle: _isRotated ? 0 : math.pi / 180, // フラグに基づいて角度を決定
              child: const Icon(
                Icons.add,
                color: Colors.black,
                size: 40,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
