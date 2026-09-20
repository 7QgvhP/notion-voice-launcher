# 変更履歴

本プロジェクトは [セマンティックバージョニング](https://semver.org/lang/ja/) に従う。

> **注記**：本リポジトリは **v1.1.4 の時点から Git 管理を開始した**。
> v1.1.4 に至るまでの変更履歴は記録されていない。

## [1.1.4] - 2026-09-20

Git 管理開始時点の内容。

### 機能

- 電源ボタン2回押し等から Notion AI の音声入力モードを直接起動する中継アプリ。
  画面を一切持たず、起動と同時に Notion へインテントを送出して即座に終了する。
- Notion が公開しているインテントアクション `notion.local.id.OPEN_NOTION_AI` に
  extra `input_mode=voice` を付けて送ることで、AI チャット画面（テキスト入力）ではなく
  録音バーが出た状態で開く。この extra は非公開仕様のため、特定手順を README に残している。
- `android.intent.action.ASSIST` を宣言し、Android の既定デジタルアシスタント枠からも
  起動できるようにしている（Nothing Ear (open) の「ボイスアシスタント」ジェスチャー用）。

### 中継アプリを必要とする理由

Nothing OS の「電源ボタンを2回押す」設定は、`Settings.Secure` の
`nt_double_tap_power_data` にパッケージ名とアクティビティ名だけを保持する形式で、
インテントの extra を持てない。そのため extra 付きインテントを送出するだけの
アプリを1つ挟む必要がある。

### ビルド

- Gradle を使わず、aapt2 / javac / d8 / zipalign / apksigner を直接呼び出す
  PowerShell スクリプト（`build.ps1`）で APK を生成する。
- バージョンと SDK レベルは `build.ps1` の変数を唯一の出典とし、`aapt2 link` の
  `--version-code` / `--version-name` でビルド時に注入する。
  `AndroidManifest.xml` には記述しない。
- JDK・build-tools・platform はバージョン番号を固定せず、パターン一致で最新のものを
  自動検出するため、ツールチェーンを更新してもビルドが壊れない。
- アイコンは `make-icon.ps1` がマイク形状を描画して生成する。未生成の場合は
  `build.ps1` が自動的に呼び出すため、初回も1コマンドでビルドが完結する。

### 画面ロックの扱い

ロック中に起動された場合、本アプリはシステムによってロック解除まで保留され、
解除された時点で Notion が音声入力モードで開く。アプリ側でロック解除（認証）を
省略することはできないため、`showWhenLocked` と `requestDismissKeyguard` を使う
方式は検証のうえ不採用とした（詳細は README を参照）。

### Git 管理開始にあたって実施した変更

- `build.ps1` のツールチェーン既定パスを `%USERPROFILE%` 基準に変更し、環境変数
  `NVL_TOOL_ROOT` で上書きできるようにした。個人環境に依存した絶対パスを除去し、
  あわせて他の PC でもそのまま動くようにするため。
- 署名鍵のパスワードの直書きをやめ、環境変数 `NVL_KEYSTORE_PASSWORD` で上書き
  できるようにした。既定値は Android のデバッグ署名と同じ慣例値。
- 署名鍵 `debug.keystore`、ビルド成果物 `build/`、生成物 `icon-preview.png` を
  `.gitignore` で除外した。
