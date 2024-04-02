import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';

import '../core/themes.dart';
import '../features/auth/auth_controller.dart';
import '../features/auth/authed_user.dart';
import '../features/photo/photo_controller.dart';
import 'onboarding_page.dart';

// TODO(masaki): ストリーム管理&オンボーディングの実装後にbuildSecondPage()など画面描画を全体的に見直す
class HomePage extends ConsumerStatefulWidget {
  const HomePage({super.key});

  static const routePath = '/home_page';

  @override
  ConsumerState<HomePage> createState() => _HomePageState();
}

class _HomePageState extends ConsumerState<HomePage> {
  late PageController _pageController;
  late bool _isContainerVisible;
  bool isLoading = false;
  bool isReady = false;
  final List<String> imagePaths = [
    'assets/images/image1.jpeg',
    'assets/images/image2.jpeg',
    'assets/images/image3.png',
    'assets/images/image4.jpeg',
    'assets/images/image5.jpeg',
    'assets/images/image6.jpeg',
    'assets/images/image7.jpeg',
    'assets/images/image8.jpeg',
    'assets/images/image9.jpeg',
    'assets/images/image10.jpeg',
  ];

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    _isContainerVisible = !ref.read(isOnBoardingCompletedProvider);
    _initDownloadPhotos();
  }

  /// 写真ダウンロード用初期化処理
  Future<void> _initDownloadPhotos() async {
    SchedulerBinding.instance.addPostFrameCallback((_) async {
      final isDownloadable = await _validateDownload();
      if (!isDownloadable) {
        setState(() => isReady = true);
        return;
      }
      await _downloadPhotos(ref);
      setState(() => isReady = true);
    });
  }

  /// 写真のダウンロードが可能な状態か確認するメソッド
  Future<bool> _validateDownload() async {
    final isSignedIn = ref.watch(userIdProvider) != null;
    if (!isSignedIn) {
      return false;
    }
    await ref.watch(authedUserStreamProvider.future);
    final authedUserAsync = ref.watch(authedUserStreamProvider).valueOrNull;
    final isReadyForUse = authedUserAsync?.classifyPhotosStatus ==
        ClassifyPhotosStatus.readyForUse;
    return isReadyForUse;
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
      final result = await ref.read(authControllerProvider).signInWithGoogle();
      await ref
          .read(photoControllerProvider)
          .upsertClassifyPhotosStatus(userId: result.userId);
      setState(() {
        isLoading = false;
      });
      await ref.read(photoControllerProvider).uploadPhotos(
            accessToken: result.accessToken,
            userId: result.userId,
          );
    } on Exception catch (e) {
      // 例外が発生した場合、エラーメッセージを表示
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString())),
        );
      }
      setState(() {
        isLoading = false;
      });
    }
  }

  List<String>? photoUrls; // Firebaseからダウンロードした写真のURLを保持

  Future<void> _downloadPhotos(WidgetRef ref) async {
    final result = await ref.read(photoControllerProvider).downloadPhotos(
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
    return !isReady
        ? SizedBox.expand(
            child: ColoredBox(color: Theme.of(context).scaffoldBackgroundColor),
          )
        : Stack(
            children: [
              Scaffold(
                floatingActionButton: FloatingActionButton(
                  onPressed: () => setState(() {
                    _isContainerVisible = !_isContainerVisible;
                  }),
                  child: _isContainerVisible
                      ? const Icon(Icons.close, size: 22)
                      : const Icon(Icons.add),
                ),
                body: SafeArea(
                  child: Stack(
                    children: [
                      RefreshIndicator(
                        color: Themes.gray.shade900,
                        backgroundColor: Themes.mainOrange,
                        onRefresh: () async {
                          final isDownloadable = await _validateDownload();
                          if (isDownloadable) {
                            await _downloadPhotos(ref);
                          }
                        },
                        child: Column(
                          children: [
                            Expanded(
                              child: GridView.builder(
                                gridDelegate:
                                    // ignore: lines_longer_than_80_chars
                                    const SliverGridDelegateWithFixedCrossAxisCount(
                                  crossAxisCount: 2,
                                ),
                                itemCount:
                                    photoUrls?.length ?? imagePaths.length,
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
                          child: Stack(
                            children: [
                              Container(
                                width: 317, // 長方形の枠の幅を317に設定
                                height: 457, // 長方形の枠の高さを327に設定
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.88),
                                  borderRadius:
                                      BorderRadius.circular(24), // 角を丸くする
                                ),
                                child: PageView(
                                  physics: const NeverScrollableScrollPhysics(),
                                  controller: _pageController,
                                  children: [
                                    _buildFirstPage(),
                                    _buildSecondPage(),
                                  ],
                                ),
                              ),
                              Positioned(
                                top: 16,
                                right: 16,
                                child: Container(
                                  width: 32,
                                  height: 32,
                                  decoration: BoxDecoration(
                                    color: Themes.gray[50],
                                    borderRadius:
                                        BorderRadius.circular(24), // 角を丸くする
                                  ),
                                  child: IconButton(
                                    padding: EdgeInsets.zero,
                                    icon: const Icon(Icons.close),
                                    onPressed: () {
                                      setState(() {
                                        _isContainerVisible = false;
                                      });
                                    },
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
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
                'あなたのGooglePhotoを\nAIで直近300枚まで解析し、\n料理の写真のみ保存します！',
                textAlign: TextAlign.left,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ),
        // const SizedBox(
        //   width: 250, // テキストの枠の幅を250に設定
        //   child: Padding(
        //     padding: EdgeInsets.only(top: 5),
        //     child: Center(
        //       child: Text(
        //         '読み込まれた画像は\n順次ホーム画面に表示されます。',
        //         textAlign: TextAlign.left,
        //         style: TextStyle(
        //           fontSize: 16,
        //         ),
        //       ),
        //     ),
        //   ),
        // ),
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
                          color: Themes.mainOrange,
                        ),
                      ),
                    ),
                  ),
                ),
                // SizedBox(
                //   width: 150, // テキストの枠の幅を250に設定
                //   child: Padding(
                //     padding: EdgeInsets.only(top: 5),
                //     child: Center(
                //       child: Text(
                //         '必ずご確認ください',
                //         textAlign: TextAlign.left,
                //         style: TextStyle(
                //           fontSize: 12,
                //           color: Themes.mainOrange,
                //         ),
                //       ),
                //     ),
                //   ),
                // ),
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
                  color: Themes.mainOrange, //色
                  width: 2, //太さ
                ),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Padding(
                padding: EdgeInsets.all(8),
                child: Text(
                  '・3分ほど、時間がかかります。'
                  '\n・アプリを終了すると、最初からやりなおしになります。'
                  '\n・必ずアプリはバックグラウンドに残してください。',
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
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: ElevatedButton(
            onPressed: _onButtonPressed,
            child: const Text(
              '写真を読みこむ',
              style: TextStyle(
                fontWeight: FontWeight.bold,
              ),
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
                ? const _LoadingDialog()
                : ref.watch(authedUserStreamProvider).when(
                      data: (authedUser) {
                        final status = authedUser.classifyPhotosStatus;
                        if (status == ClassifyPhotosStatus.readyForUse) {
                          // TODO(masaki): TextStyleはtheme側で定義
                          return Column(
                            children: [
                              const Text(
                                // ignore: lines_longer_than_80_chars
                                '初期表示用の画像の読み込みが完了しました。\n下記ボタンから、画像をダウンロードしてください。',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const Gap(48),
                              ElevatedButton(
                                onPressed: () async {
                                  await _downloadPhotos(ref);
                                  setState(() => _isContainerVisible = false);
                                },
                                child: const Text(
                                  'ダウンロードする',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          );
                        } else if (status == ClassifyPhotosStatus.processing) {
                          return const _LoadingDialog();
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
      ],
    );
  }
}

class _LoadingDialog extends StatelessWidget {
  const _LoadingDialog();

  @override
  Widget build(BuildContext context) {
    return const Column(
      children: [
        Text(
          '画像を処理中です...\n3分ほどお待ちください。\n他のアプリに切り替えても大丈夫です。',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        Gap(16),
        CircularProgressIndicator(),
      ],
    );
  }
}
