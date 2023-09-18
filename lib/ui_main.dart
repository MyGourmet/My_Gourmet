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
          GridView.builder(
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
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
          Positioned(
            top: (MediaQuery.of(context).size.height - 327) / 2, // 縦方向中央に配置
            left: (MediaQuery.of(context).size.width - 317) / 2, // 横方向中央に配置
            child: Container(
              width: 317, // 長方形の枠の幅を317に設定
              height: 327, // 長方形の枠の高さを327に設定
              color: Colors.white.withOpacity(0.88),
              child: Center(
                child: Container(
                  width: 251, // テキストの枠の幅を251に設定
                  child: Center(
                    child: Text(
                      'My Goumetへようこそ！\n以下のボタンを押すと、Google Photosの画像から\n料理の画像のみを判別して\nダウンロードできます！',
                      textAlign: TextAlign.left,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
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