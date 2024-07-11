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
