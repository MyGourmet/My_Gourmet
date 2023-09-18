import 'package:flutter/material.dart';

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

class RoundedButton extends StatelessWidget {
  final String label;

  const RoundedButton({required this.label});

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

class MyHomePage extends StatelessWidget {
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
      body: Stack(
        children: [
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            height: 80, // 画像と重ならないように上部を55に設定
            child: Container(
              color: Colors.black, // 上部の背景色を黒に設定
            ),
          ),
          Positioned.fill(
            top: 55,
            child: GridView.builder(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
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
          const Positioned(
            top: 15, // アプリの最上部に配置
            left: 0, // 左端に配置
            right: 0, // 右端に配置
            child: Padding(
              padding: EdgeInsets.all(16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  RoundedButton(label: 'ラーメン'),
                  RoundedButton(label: '和食'),
                  RoundedButton(label: 'カフェ'),
                  RoundedButton(label: 'その他'),
                ],
              ),
            ),
          ),
          Positioned(
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
                        'MyGourmetへようこそ！\n以下のボタンを押すと、Google Photoの画像から\n料理の画像のみを判別して\nダウンロードできます！',
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
          // SizedBox(height: 30),
          Positioned(
            top: (MediaQuery.of(context).size.height - 327) / 2 +
                405, // プラスボタンの上辺を配置
            left: (MediaQuery.of(context).size.width - 60) / 2, // プラスボタンの左辺を配置
            child: Container(
              width: 60, // プラスボタンの幅
              height: 60, // プラスボタンの高さ
              decoration: const BoxDecoration(
                color: Colors.black, // プラスボタンの背景色
                shape: BoxShape.circle, // 円形の形状
              ),
              child: const Center(
                child: Icon(
                  Icons.add,
                  color: Color(0xFFEF913A),
                  size: 40, // プラスボタンのアイコンサイズ
                ),
              ),
            ),
          ),
        ],
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
