# notion-voice-launcher

コミットの書式、バージョン、タグ、CHANGELOG の規約（全プロジェクト共通）は、ここには書かない。このファイルは、このリポジトリ固有の事実だけを書く。

## 概要
Nothing Phone (4a) のジェスチャーから、Notion AI の音声入力モードを直接起動する Android の中継アプリ。画面を持たず、起動と同時に Notion へインテントを送って終了する。

## 技術スタックと主要ディレクトリ
- Java / Android（minSdk 26、targetSdk 35）。Gradle は使わず、Android SDK のツールを `build.ps1` から直接呼ぶ。
- `src/dev/local/notionvoice/LauncherActivity.java`: 中継処理の本体（唯一のソース）
- `AndroidManifest.xml`: 宣言のみ（バージョンと SDK レベルは持たない）
- `res/`: 文字列・色・アイコン画像
- `build.ps1`: ビルド一式、`make-icon.ps1`: アイコンの生成
- 詳細は [docs/architecture.md](docs/architecture.md)

## コマンド
- ビルド: `powershell -File build.ps1`（出力は `build\notion-voice-launcher.apk`）
- テスト: なし（自動テストはない。確認は、ビルドが通ることと実機での動作）
- lint: なし
- アイコンの再生成: `powershell -File make-icon.ps1`（`res/` 配下の画像を上書きする）
- ビルドには `%USERPROFILE%\android-build-tools`（または環境変数 `NVL_TOOL_ROOT`）配下の JDK と Android SDK が必要。自動対応の専用クローンでツールがなければ、完了報告に「確認できていない点」として書く。
- 実機での動作（インテントの起動）は、手元でしか確認できない。
- ※ 自動対応でコマンドを実行するには、dev-hub の `tools\claude-auto\config.ps1` の `$ExtraTools` で許可が必要。

## コーディング規約
- コメント・Javadoc・文字列リソースのコメントは日本語。
- 定数は `private static final` で、名前は大文字のスネークケース（例: `ACTION_OPEN_NOTION_AI`）。
- PowerShell スクリプトは UTF-8（BOM 付き）。
- `CHANGELOG.md` の箇条書きは `-` で、文体は「だ・である」。

## バージョンの記録場所
リリースのときに、次をすべて同じコミットで更新する。
- `build.ps1` の冒頭の `$versionName`（バージョンの唯一の出典）
- `build.ps1` の冒頭の `$versionCode`（リリースのたびに 1 ずつ増やす整数）
- `README.md` の冒頭の「バージョン」の行
- `CHANGELOG.md` の見出し（`## [X.Y.Z] - YYYY-MM-DD`）

`AndroidManifest.xml` には、バージョンを書かない（ビルド時に `aapt2` が注入する）。
GitHub Releases は作らない（GitHub Actions がなく、APK は配布していないため。タグだけでリリースとする）。

## ドキュメント更新ルール
今後の開発で、次の変更を行う際は、同じ作業の中で該当ドキュメントも更新すること。
- 機能の追加・変更・削除 → `docs/spec.md`、`docs/usage.md`、`CHANGELOG.md`
- 構成や設計の変更 → `docs/architecture.md`
- 設定項目の追加・変更 → `docs/configuration.md`
- 技術選定や設計方針を変える判断 → 新しい ADR を `docs/adr/` に追加する（既存の ADR は書き換えず、ステータスを Superseded にして、新しい ADR から参照する）
- バージョンを上げるとき → `CHANGELOG.md` に新しいバージョンの節（`## [X.Y.Z] - YYYY-MM-DD`）を追加し、「バージョンの記録場所」のファイルをすべて同じコミットで更新する

## 注意事項
- `debug.keystore`（署名鍵）、`build/`、`icon-preview.png` は Git 管理外。署名鍵はコミットしない。
- `.keystore`、`.apk`、`.png` はバイナリとして扱う（`.gitattributes` で指定済み）。
- Notion のインテントの `input_mode=voice` は非公開の仕様。Notion の更新で動かなくなった場合の確認手順は [docs/usage.md](docs/usage.md) にある。
