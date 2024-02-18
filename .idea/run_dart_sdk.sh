#!/bin/bash

# fvm_config.jsonからFlutterバージョンを取得
FLUTTER_VERSION=$(cat "./.fvmrc" | grep flutter | cut -d '"' -f 4)

# 'fvm/versions'ディレクトリがホームディレクトリ配下にあることを前提にしている
FVM_VERSIONS_DIR="$HOME/fvm/versions"

if [[ -z "$FVM_VERSIONS_DIR" ]]; then
    echo "The fvm/versions directory was not found under $HOME."
    exit 1
fi

# Dart SDKのパスを特定
DART_SDK_PATH="$FVM_VERSIONS_DIR/$FLUTTER_VERSION/bin/dart"

# 渡された引数を含めてdartコマンドを実行
$DART_SDK_PATH "$@"
