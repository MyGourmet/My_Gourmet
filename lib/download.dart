import 'package:flutter/material.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart'; // この行はおそらくプロジェクト固有の設定で使用されています。

// import 'firebase_options.dart'; // この行はおそらくプロジェクト固有の設定で使用されています。

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Google SignIn Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: DownloadImagesFromStorage(),
    );
  }
}

class DownloadImagesFromStorage extends StatefulWidget {
  @override
  _DownloadImagesFromStorageState createState() =>
      _DownloadImagesFromStorageState();
}

class _DownloadImagesFromStorageState extends State<DownloadImagesFromStorage> {
  List<String>? imageUrls;

  Future<void> _downloadImages() async {
    try {
      final storage = FirebaseStorage.instance;
      ListResult result = await storage
          .ref()
          .child('photo-jp-my-gourmet-image-classification-2023-08/')
          .list();
      List<String> urls = [];
      for (var item in result.items) {
        final url = await item.getDownloadURL();
        urls.add(url);
      }
      setState(() {
        imageUrls = urls;
      });
    } catch (e) {
      print("An error occurred: $e");
      setState(() {
        imageUrls = [];
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Download Images from Firebase Storage'),
        actions: [
          IconButton(
            icon: Icon(Icons.download),
            onPressed: () {
              _downloadImages().then((_) {
                setState(() {});
              });
            },
          ),
        ],
      ),
      body: Center(
        child: imageUrls != null
            ? GridView.builder(
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3, // 一行に表示するアイテム数
                ),
                itemCount: imageUrls!.length,
                itemBuilder: (context, index) {
                  return AspectRatio(
                    aspectRatio: 1.0, // 正方形になるように
                    child: Image.network(
                      imageUrls![index],
                      fit: BoxFit.cover,
                    ),
                  );
                },
              )
            : Text('右上のダウンロードボタンを押してください。'),
      ),
    );
  }
}
