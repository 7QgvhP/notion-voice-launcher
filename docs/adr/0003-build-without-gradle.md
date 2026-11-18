# 0003. Gradle を使わず、SDK のツールを直接呼んでビルドする

- ステータス: Accepted
- 日付: 2026-09-20 以前

## 背景（Context）

ソースは Java のアクティビティ1つと、少数のリソースだけである。

## 決定内容（Decision）

Gradle を使わず、PowerShell スクリプト（`build.ps1`）から `aapt2`、`javac`、`d8`、`zipalign`、`apksigner` を直接呼んで APK を生成する。

## 理由と検討した代替案（Consequences / Alternatives）

- ビルドに必要なのは JDK と Android SDK だけになり、ビルドの手順はすべて `build.ps1` に書かれている。
- 一方で、依存ライブラリの追加や lint など、Gradle が提供する機能は使えない。
- 検討した代替案: Gradle（Android Gradle Plugin）によるビルド。
