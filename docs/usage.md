# 使用方法

## 前提条件

- ビルドする PC: Windows、PowerShell、JDK と Android SDK（配置は [development.md](development.md#開発環境の構築)）。
- 端末: Nothing Phone (4a)、Notion アプリ（パッケージ `notion.id`）。
- インストールに `adb` を使う場合は、端末で USB デバッグを有効にする。

## インストール

```
powershell -File build.ps1
```

出力は `build\notion-voice-launcher.apk`（約 17 KB）。

```
adb install -r build\notion-voice-launcher.apk
```

## 基本的な使い方

アプリ一覧の「Notion 音声入力」をタップすると、Notion AI が音声入力モードで開く。実際の用途は、下記のトリガーへの割り当て。

Notion 側が音声入力モードに対応しているかは、このアプリを使わずに次で確認できる。

```
adb shell am start -a notion.local.id.OPEN_NOTION_AI --es input_mode voice
```

## ユースケース別の手順

### 電源ボタン2回押しで起動する

設定 → 特別な機能 → ジェスチャー → 電源ボタンを2回押す → アプリ →「Notion 音声入力」

### Essential Key で起動する

純正のリマップ機能がないため、ADB で Essential Space を無効化したうえで、Key Mapper 等からこのアプリを起動する。

```
adb shell pm disable-user --user 0 com.nothing.ntessentialspace
adb shell pm disable-user --user 0 com.nothing.ntessentialrecorder
```

元に戻す場合は、`pm enable` を実行して端末を再起動する。

### Nothing Ear (open) で起動する

1. Nothing X で「ダブルピンチ＆ホールド」に**ボイスアシスタント**を割り当てる。
2. 設定 → アプリ → 既定のアプリ → デジタルアシスタントアプリ で、このアプリを選ぶ。

Nothing X の「Voice AI → ChatGPT」は ChatGPT アプリ固定のため、差し替えられない。

### ロック中でも解除操作なしで音声入力まで到達する

アプリ側ではロック解除を省略できない（[ADR 0005](adr/0005-do-not-bypass-keyguard.md)）。
Android の Smart Lock（設定 → セキュリティとプライバシー → 追加のセキュリティ設定 → 拡張ロック解除）で、「信頼できるデバイス」に Ear (open) を登録するか、「信頼できる場所」を設定する。
ロックが信頼状態の間は、電源ボタン2回押しだけで音声入力モードまで到達する。

## よくあるエラーと対処

| 症状 | 原因と対処 |
|---|---|
| 「Notion アプリが見つかりませんでした」と表示される | Notion が未インストール、または Notion の更新でアクションが変わった。`adb shell dumpsys package notion.id` でアクションを、APK の dex 文字列で extra のキーを確認し直す |
| Notion は開くが、音声入力モードにならない | extra（`input_mode=voice`）の仕様が変わった可能性がある。上と同じ手順で確認する |
| `adb install` が失敗する | `debug.keystore` を削除して再生成すると署名鍵が変わり、上書きインストールできない。一度アンインストールしてからインストールする |
| ビルドで「JDK が見つかりません」などと出て止まる | ツールチェーンが探索パターンに一致しない。配置を [development.md](development.md#開発環境の構築) で確認する |
