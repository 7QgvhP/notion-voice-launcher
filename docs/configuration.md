# 設定リファレンス

アプリ自体に設定項目はない。以下は、ビルドとアイコン生成の設定。

## 環境変数

| 名前 | 説明 | 型 | デフォルト値 | 必須 |
|---|---|---|---|---|
| `NVL_TOOL_ROOT` | JDK と Android SDK を探すフォルダ（`build.ps1`） | パス | `%USERPROFILE%\android-build-tools` | いいえ |
| `NVL_KEYSTORE_PASSWORD` | 署名鍵 `debug.keystore` のパスワード（`build.ps1`） | 文字列 | Android のデバッグ署名の慣例値（`build.ps1` を参照） | いいえ |

## 設定ファイル

### `build.ps1` の冒頭の変数

| 名前 | 説明 | 型 | デフォルト値 | 必須 |
|---|---|---|---|---|
| `$versionCode` | APK の versionCode。リリースのたびに 1 ずつ増やす | 整数 | （現在の値は `build.ps1`） | はい |
| `$versionName` | APK の versionName。バージョンの唯一の出典 | 文字列 | （現在の値は `build.ps1`） | はい |
| `$minSdk` | 最小 SDK レベル | 整数 | `26` | はい |
| `$targetSdk` | ターゲット SDK レベル | 整数 | `35` | はい |

### `make-icon.ps1` の冒頭の変数

| 名前 | 説明 | 型 | デフォルト値 | 必須 |
|---|---|---|---|---|
| `$glyphRatio` | 出力キャンバスに対するマイク形状の占有率 | 小数 | `0.53` | はい |

マイク形状の寸法の定数は、`make-icon.ps1` の「マイク形状の寸法」の節を参照。

## コマンドラインオプション

なし（`build.ps1`、`make-icon.ps1` とも引数を取らない）。
