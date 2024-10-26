## 環境構築

### 事前準備

FVMが未インストールの場合、[こちらの記事](https://zenn.dev/altiveinc/articles/flutter-version-management)
を参考に設定を行う。  
※
既にインストール済みで2系を使い続けたい場合、3系との共存を検討（[参考](https://zenn.dev/altiveinc/articles/flutter-version-management-3#v2%E3%81%A8v3%E3%81%AE%E5%85%B1%E5%AD%98))

### セットアップ

#### 1. 本リポジトリをクローン後、プロジェクトのルートディレクトリにて以下のコマンドを実行する。

```bash
make setup
```

#### 2. `.env.example`をコピーして`.env`を作成する。
PROD_API_URLとDEV_API_URLをNotionを参照して変更する。

```.dotenv
PROD_API_URL=https://dummy-prod-url
DEV_API_URL=https://dummy-dev-url
```

実際のURLは以下を参照：  
https://www.notion.so/masakisato/11a5050794ac414f8f0ef9525ae13809?pvs=4

#### 3. Firebaseにsha1証明書を登録する。
   my-gourmetとmy-gourmet-devに下記で出力されたsha1証明書を登録する。
```
keytool -list -v -keystore ~/.android/debug.keystore -alias androiddebugkey -storepass android -keypass android
```

詳細は、以下のURLを参照：  
https://zenn.dev/flutteruniv/books/flutter-textbook/viewer/make-chat

## 開発手法
### Issue管理
全てNotion上で行う。
以下スペース(アクセス権限必要)：  
https://www.notion.so/masakisato/MyGourmet-4932e4554a4246849be5f53fdfa4c0c8

### PR作成方法
GitHubとNotionの相互紐付けを行う。  
1. NotionのドキュメントIDを確認  
![CleanShot 2024-09-02 at 07 48 44](https://github.com/user-attachments/assets/a4ba90b2-5304-4794-bf15-eabd8fb47567)
2. PRのタイトルに記載  
![CleanShot 2024-09-02 at 07 51 02@2x](https://github.com/user-attachments/assets/fb118922-72e6-4745-b18f-eced891762a5)

## ディレクトリ構成
### feature ディレクトリ
- 各機能ごとに`feature`ディレクトリに格納する、`feature-first`という方式を取っている
- UIからリポジトリまでを`feature`ディレクトリの中に格納する

### core ディレクトリ
- featureを横断して利用するものはこの`core`ディレクトリへ格納する
- UIコンポーネントについては、featureを超えて共通化する場合は、`core` ディレクトリ内の `widgets` ディレクトリへ 格納する
- UIが存在せずに外部サービスと接続するようなファイル(ie. `analytics_repository.dart`)は、`feature`ディレクトリではなく`core`ディレクトリへ入れることを検討

```text
.
├── core
│   ├── analytics_repository.dart
│   ├── constants.dart
│   ├── themes.dart
│   └── widgets
│       ├── confirm_dialog.dart
│       └── success_snack_bar.dart
├── features
│   ├── auth
│   │   ├── auth_controller.dart
│   │   ├── auth_repository.dart
│   │   ├── authed_user.dart
│   │   ├── authed_user.freezed.dart
│   │   ├── authed_user.g.dart
│   │   └── my_page.dart
│   └── root_page.dart
└── main.dart


```
