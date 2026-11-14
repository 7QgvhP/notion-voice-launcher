# 開発者向けガイド

## 開発環境の構築

ビルドには JDK と Android SDK が必要。`build.ps1` は、次の場所から最新のものを自動で探す（[ADR 0006](adr/0006-auto-detect-toolchain.md)）。

| 対象 | 探索パターン |
|---|---|
| JDK | `$toolRoot\jdk\jdk-*` |
| build-tools | `$toolRoot\sdk\build-tools\*` |
| platform | `$toolRoot\sdk\platforms\android-*` |

`$toolRoot` の既定値は `%USERPROFILE%\android-build-tools`。環境変数 `NVL_TOOL_ROOT` で変えられる（[configuration.md](configuration.md)）。
見つからない場合は、どのパターンに一致しなかったかを示して停止する。

TODO(要確認): JDK と Android SDK の入手・展開の手順（どのファイルをどこから取得したか）は、リポジトリ内に記録がない。

## ビルド

```
powershell -File build.ps1
```

- 出力は `build\notion-voice-launcher.apk`。`build/` は毎回作り直す。
- アイコンが未生成なら、`make-icon.ps1` を自動で実行する。
- 初回は、署名鍵 `debug.keystore` を生成する（Git 管理外）。削除すると鍵が変わり、端末への上書きインストールができなくなる。

## テスト

自動テストはない。確認は、ビルドが通ることと、実機での動作で行う（手順は [usage.md](usage.md)）。

## lint / フォーマット

なし。

## アイコンの描き直し

```
powershell -File make-icon.ps1
```

- マイク形状は 256x256 の基準座標で定義している。大きさは冒頭の `$glyphRatio`（キャンバスに対する占有率）で、形はそれに続く寸法の定数で調整する。
- 前景（288x288）、旧形式用（144x144）、確認用プレビュー（`icon-preview.png`、Git 管理外）を、同じ形状から生成する。`res/` 配下のコミット済みの画像を上書きする。

## ブランチ運用とコミット

全プロジェクト共通の Git 運用ルールに従う。このリポジトリ固有の事情はない。

## リリース手順

1. 更新するファイルは、[CLAUDE.md](../CLAUDE.md) の「バージョンの記録場所」を参照する。`build.ps1` の `$versionCode` は、リリースのたびに 1 ずつ増やす。
2. GitHub Actions はない。タグを push しても、ビルドや配布は行われない（GitHub Releases は作らない）。
