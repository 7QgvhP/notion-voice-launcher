# notion-voice-launcher

共通ルール（コミットの書式、バージョン、タグ、CHANGELOG）は、ここには書きません。このファイルは、このリポジトリ固有の事実だけを書きます。

## 概要
Nothing Phone (4a) で、電源ボタン2回押し・Essential Key・Ear (open) のジェスチャーから、Notion AI の音声入力モードを直接起動するための、Android の中継アプリです。画面を持たず、起動と同時に Notion へインテントを送って終了します。

## 構成と技術
- Java / Android。Gradle は使わず、Android SDK の素のツールだけで APK を作ります。
- `src/dev/local/notionvoice/LauncherActivity.java`: 中継処理の本体
- `AndroidManifest.xml`: 宣言のみ（バージョンと SDK レベルは持たない）
- `build.ps1`: ビルド一式
- `make-icon.ps1`: アイコンの生成
- `res/`: 文字列・色・アイコン画像
- 出力先の `build/` は Git 管理外

## ビルド・テストの手順
自動テストはありません。確認は、ビルドが通ることと、実機での動作で行います。
```
powershell -File build.ps1
```
- ビルドには、`%USERPROFILE%\android-build-tools`（または環境変数 `NVL_TOOL_ROOT`）配下の JDK と Android SDK が必要です。自動対応の専用クローンでは、ツールがなければ実行できないので、完了報告に「確認できていない点」として書いてください。
- 実機での動作（インテントの起動）は、手元でしか確認できません。
- ※ 自動対応でビルドを実行するには、dev-hub の `tools\claude-auto\config.ps1` の `$ExtraTools` で許可が必要です。

## バージョンの記録場所
リリースのときに、次をすべて同じコミットで更新します。
- `build.ps1` の冒頭の `$versionName`（バージョンの唯一の出典）
- `build.ps1` の冒頭の `$versionCode`（リリースのたびに 1 ずつ増やす整数）
- `README.md` の1行目の見出し「# Notion 音声入力ランチャー vX.Y.Z」
- `CHANGELOG.md` の見出し（`## [X.Y.Z] - YYYY-MM-DD`）

`AndroidManifest.xml` には、バージョンを書きません（ビルド時に `aapt2` が注入します）。

## 注意事項
- `.keystore`、`.apk`、`.png` は、バイナリとして扱います（`.gitattributes` で指定済み）。署名鍵はコミットしないでください。
- Notion のインテントの `input_mode=voice` は非公開の仕様です。特定した手順は README にあります。
- `CHANGELOG.md` の箇条書きは `-` で、文体は「だ・である」です。
