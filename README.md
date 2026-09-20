# Notion 音声入力ランチャー v1.1.4

Nothing Phone (4a) で、電源ボタン2回押し・Essential Key・Ear (open) のジェスチャーから
**Notion AI の音声入力モードを直接起動**するための中継アプリ。

画面を持たず、起動と同時に Notion へインテントを投げて即座に終了する。

## 仕組み

Notion の Android アプリは、外部から起動可能なインテントアクションを公開している。

| 項目 | 値 |
|---|---|
| パッケージ名 | `notion.id` |
| アクション | `notion.local.id.OPEN_NOTION_AI` |
| 受け口 | `notion.local.id.MainActivity`（`category.DEFAULT` 付きで exported） |
| 音声モード指定 extra | `input_mode` = `voice`（String） |

extra を省略すると AI チャット画面（テキスト入力）で開く。`input_mode=voice` を付けると
録音バーが出た状態で開く。

ADB から直接叩いて確認する場合:

```
adb shell am start -a notion.local.id.OPEN_NOTION_AI --es input_mode voice
```

### なぜ中継アプリが必要か

Nothing OS の電源ボタン2回押し設定は、`Settings.Secure` の `nt_double_tap_power_data` に
**パッケージ名とアクティビティ名だけ**を保持する形式で、extra を持てない。

```json
{"type":8,"app_type":8,"torch_type":4,
 "pkgName":"com.nothing.soundrecorder","info":"com.nothing.soundrecorder.MainActivity","uid":0}
```

そのため「extra 付きインテントを投げるだけのアプリ」を1つ挟む必要がある。

## 構成

| ファイル | 役割 |
|---|---|
| `src/dev/local/notionvoice/LauncherActivity.java` | 中継処理の本体 |
| `AndroidManifest.xml` | 宣言のみ。バージョンと SDK レベルは持たない |
| `build.ps1` | ビルド一式。**バージョンの唯一の出典** |
| `make-icon.ps1` | アイコン生成。マイク形状の寸法もここに集約 |
| `res/` | 文字列・色・アイコン画像 |

## ビルド

Gradle は使わず、Android SDK の素のツールだけで APK を生成する。

```
powershell -File build.ps1
```

アイコンが未生成なら `build.ps1` が `make-icon.ps1` を自動実行するため、初回もこの
1コマンドで完結する。出力は `build\notion-voice-launcher.apk`（約 20.7 KB）。

インストール:

```
adb install -r build\notion-voice-launcher.apk
```

### バージョンを上げる

`build.ps1` 冒頭の `$versionCode` と `$versionName` だけを書き換える。
`AndroidManifest.xml` には記述せず、`aapt2 link --version-code/--version-name` が
ビルド時に注入する。`minSdk` / `targetSdk` も同様に `build.ps1` が唯一の出典。

### ツールチェーン

ツールチェーンは `$toolRoot` 配下を探索する。既定値は `%USERPROFILE%\android-build-tools`
で、環境変数 `NVL_TOOL_ROOT` を設定するとそちらが優先される。
個別のバージョン番号は固定せず、以下のパターンから最新のものを自動検出するため、
JDK や build-tools を更新してもビルドは壊れない。

| 対象 | 探索パターン |
|---|---|
| JDK | `$toolRoot\jdk\jdk-*` |
| build-tools | `$toolRoot\sdk\build-tools\*` |
| platform | `$toolRoot\sdk\platforms\android-*` |

見つからない場合は、どのパターンに一致しなかったかを示して停止する。

### アイコンを描き直す

```
powershell -File make-icon.ps1
```

マイク形状は 256x256 の基準座標で定義してある。大きさを変えるなら
`make-icon.ps1` 冒頭の `$glyphRatio`（キャンバスに対する占有率）を、
形そのものを変えるなら続く寸法定数を調整する。前景（288x288）・旧形式用（144x144）・
確認用プレビュー（`icon-preview.png`）が同じ形状から生成される。

## トリガーの割り当て

### 電源ボタン2回押し

設定 → 特別な機能 → ジェスチャー → 電源ボタンを2回押す → アプリ →「Notion 音声入力」

### Essential Key

純正のリマップ機能が無いため、ADB で Essential Space を無効化したうえで
Key Mapper 等からこのアプリを起動する。

```
adb shell pm disable-user --user 0 com.nothing.ntessentialspace
adb shell pm disable-user --user 0 com.nothing.ntessentialrecorder
```

元に戻す場合は `pm enable` を実行して端末を再起動する。

### Nothing Ear (open)

Nothing X で「ダブルピンチ＆ホールド」に**ボイスアシスタント**を割り当てたうえで、
Android の既定デジタルアシスタントをこのアプリに変更する
（本アプリは `android.intent.action.ASSIST` を宣言済み）。

設定 → アプリ → 既定のアプリ → デジタルアシスタントアプリ

なお Nothing X の「Voice AI → ChatGPT」は ChatGPT アプリ固定のため差し替え不可。

## 画面ロックについて

ロック中に起動された場合、本アプリはシステムによってロック解除まで保留され、
解除された時点で Notion が音声入力モードで開く。

**アプリ側でロック解除（認証）を省略することはできない。** 以下の方式を実機で検証したが、
いずれも採用していない。

- `showWhenLocked` + `requestDismissKeyguard`
  指紋認証プロンプト（ALTERNATE_BOUNCER）を即座に出すところまでは動作するが、
  認証自体は省略できず（`dumpsys trust` で `deviceLocked=1` のまま）、
  さらにアクティビティがロック画面を覆い隠すため、プロンプトが自動で引っ込んだ際に
  壁紙だけの画面に取り残されて解除しづらくなる。

解除操作なしで音声入力まで到達したい場合は、Android の **Smart Lock**
（設定 → セキュリティとプライバシー → 追加のセキュリティ設定 → 拡張ロック解除）で
「信頼できるデバイス」に Ear (open) を登録するか、「信頼できる場所」を設定する。
ロックが信頼状態になっている間は、電源ボタン2回押しだけで音声入力モードまで到達する。

## 注意

- Notion 側のアクションと extra は非公開仕様のため、Notion アプリの更新で
  動作しなくなる可能性がある。その場合は `adb shell dumpsys package notion.id` で
  アクションを、APK の dex 文字列で extra キーを再確認する。
- 検証時の Notion バージョンでは、コールドスタート・ウォームスタートの両方で
  音声録音モードに入ることを確認済み。
- `debug.keystore` は個人利用のためのローカル署名鍵で、`.gitignore` 対象。
  削除した場合は次回ビルド時に再生成されるが、鍵が変わるため既存アプリへの
  上書きインストールは失敗する（一度アンインストールが必要）。
  パスワードは Android のデバッグ署名と同じ慣例値を既定とし、環境変数
  `NVL_KEYSTORE_PASSWORD` で上書きできる。
