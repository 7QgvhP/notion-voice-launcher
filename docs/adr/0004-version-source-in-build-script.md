# 0004. バージョンと SDK レベルの出典を `build.ps1` に一元化する

- ステータス: Accepted
- 日付: 2026-09-20 以前

## 背景（Context）

APK のバージョン（versionCode / versionName）と SDK レベル（minSdk / targetSdk）は、通常は `AndroidManifest.xml` かビルド設定に書く。

## 決定内容（Decision）

これらの値は `build.ps1` の冒頭の変数だけに書き、`AndroidManifest.xml` には書かない。ビルド時に `aapt2 link` の `--version-code`、`--version-name`、`--min-sdk-version`、`--target-sdk-version` で注入する。

## 理由と検討した代替案（Consequences / Alternatives）

- バージョンを上げるときに変えるのは `build.ps1` の2つの変数だけになる。
- 検討した代替案: `AndroidManifest.xml` に書く。
