## 環境構築

プロジェクトのルートディレクトリにて以下のコマンドを実行する。
```bash
make setup
```

本プロジェクトはFlutterのバージョン管理に[fvm](https://fvm.app/)を利用している。  
FVMのインストール・設定については、[こちらの記事](https://zenn.dev/riscait/articles/flutter-version-management)を参照。  
fvmをインストール後にプロジェクトのルートディレクトリで下記のコマンドを実行する。

```bash
fvm use 3.13.7
```
※バージョンは随時更新するため`.fvm/fvm_config.json`を参照すること。