import 'package:flutter/material.dart';
import 'dart:math' as math;

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: MyHomePage(),
    );
  }
}

class CategoryButton extends StatelessWidget {
  final String label;

  const CategoryButton({required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Color(0xFFD9D9D9),
        borderRadius: BorderRadius.circular(15.0), // 角を丸くする
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
    );
  }
}

class MyRotatingButton extends StatefulWidget {
  final ValueChanged<bool> onVisibilityChanged; // コンテナの表示状態を通知するためのコールバック

  MyRotatingButton({required this.onVisibilityChanged});

  @override
  _MyRotatingButtonState createState() => _MyRotatingButtonState();
}

class _MyRotatingButtonState extends State<MyRotatingButton> {
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

class MyHomePage extends StatefulWidget {
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  bool _isContainerVisible = true;
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
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Stack(
          children: [
            Container(
              height: MediaQuery.of(context).size.height,
              width: MediaQuery.of(context).size.width,
              color: Colors.black,
              child: Column(children: [
                const Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      CategoryButton(label: 'ラーメン'),
                      CategoryButton(label: '和食'),
                      CategoryButton(label: 'カフェ'),
                      CategoryButton(label: 'その他'),
                    ],
                  ),
                ),
                Expanded(
                  child: GridView.builder(
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 3, // 3列
                    ),
                    itemCount: imagePaths.length,
                    itemBuilder: (context, index) {
                      return Image.asset(
                        imagePaths[index],
                        fit: BoxFit.cover, // 画像を正方形に表示
                      );
                    },
                  ),
                ),
              ]),
            ),
            Visibility(
              visible: _isContainerVisible,
              child: Positioned(
                top: (MediaQuery.of(context).size.height - 327) / 2, // 縦方向中央に配置
                left: (MediaQuery.of(context).size.width - 317) / 2, // 横方向中央に配置
                child: Container(
                  width: 317, // 長方形の枠の幅を317に設定
                  height: 327, // 長方形の枠の高さを327に設定
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.88),
                    borderRadius: BorderRadius.circular(30.0), // 角を丸くする
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        width: 250, // テキストの枠の幅を250に設定
                        child: const Center(
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
                        onPressed: () {
                          // ここにボタンが押された時の処理を追加
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Color(0xFFEF913A), // ボタンの背景色を設定
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30.0), // 角を丸くする
                          ),
                          minimumSize: Size(250, 50),
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
                  ),
                ),
              ),
            ),
            // SizedBox(height: 30),
            MyRotatingButton(
              onVisibilityChanged: (isVisible) {
                setState(() {
                  _isContainerVisible = isVisible; // コンテナの表示状態を更新
                });
              },
            ),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: Colors.black,
        selectedFontSize: 0, // 選択時のフォントサイズを0に設定
        unselectedFontSize: 0, // 非選択時のフォントサイズを0に設定
        items: const [
          BottomNavigationBarItem(
            icon: Padding(
              padding: EdgeInsets.only(top: 10), // 上側の余白を設定
              child: Icon(
                Icons.photo,
                size: 40, // アイコンのサイズを設定
                color: Color(0xFFEF913A), // アイコン本体の色を指定
              ),
            ),
            label: '',
          ),
          BottomNavigationBarItem(
            icon: Padding(
              padding: EdgeInsets.only(top: 10), // 上側の余白を設定
              child: Icon(
                Icons.map,
                size: 40, // アイコンのサイズを設定
                color: Color(0xFFEF913A), // アイコン本体の色を指定
              ),
            ),
            label: '',
          ),
        ],
      ),
    );
  }
}
