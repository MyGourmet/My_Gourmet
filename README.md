## 環境構築

### 事前準備
FVMが未インストールの場合、[こちらの記事](https://zenn.dev/altiveinc/articles/flutter-version-management)を参考に設定を行う。  
※ 既にインストール済みで2系を使い続けたい場合、3系との共存設定を行う（[参考](https://zenn.dev/altiveinc/articles/flutter-version-management-3#v2%E3%81%A8v3%E3%81%AE%E5%85%B1%E5%AD%98))

### セットアップ
本リポジトリをクローン後、プロジェクトのルートディレクトリにて以下のコマンドを実行する。
```bash
make setup
```

`.env.example`の形式で、ファイル環境変数用のファイルを作成する。  
```.env.example
PROD_API_URL=https://dummy-prod-url
DEV_API_URL=https://dummy-dev-url
```
実際のURLは以下を参照：
https://www.notion.so/masakisato/11a5050794ac414f8f0ef9525ae13809?pvs=4
