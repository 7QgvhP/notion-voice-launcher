# Notion 音声入力ランチャー

Nothing Phone (4a) のジェスチャーから、Notion AI の音声入力モードを直接起動する Android の中継アプリ。

- バージョン: 1.1.8

## 概要

Notion AI の音声入力モードは、extra（`input_mode=voice`）付きのインテントでしか直接開けない。
一方、Nothing OS の電源ボタン2回押しの設定は、起動するアプリを指定できるだけで extra を渡せない。
このアプリは、起動されると extra 付きのインテントを Notion に送って即座に終了する。画面は持たない。

## 主な機能

- 起動と同時に、Notion AI を音声入力モードで開く
- 電源ボタン2回押し、Essential Key（Key Mapper 等を経由）、デジタルアシスタント枠（Nothing Ear (open) のジェスチャー）から起動できる
- Notion が見つからない場合は、エラーをトースト表示する

## クイックスタート

前提：Windows、PowerShell、`%USERPROFILE%\android-build-tools` に JDK と Android SDK（詳細は [docs/development.md](docs/development.md)）。

```
powershell -File build.ps1
adb install -r build\notion-voice-launcher.apk
```

端末側の設定（トリガーの割り当て）は [docs/usage.md](docs/usage.md) を参照。

## ドキュメント

| ファイル | 内容 |
|---|---|
| [docs/spec.md](docs/spec.md) | 仕様（何をするか） |
| [docs/usage.md](docs/usage.md) | 使用方法（インストール、トリガーの割り当て、トラブル対処） |
| [docs/architecture.md](docs/architecture.md) | 設計（どう作っているか） |
| [docs/development.md](docs/development.md) | 開発者向けガイド（ビルド環境、リリース手順） |
| [docs/configuration.md](docs/configuration.md) | 設定リファレンス（環境変数、ビルド設定） |
| [docs/adr/](docs/adr/README.md) | 設計判断記録（ADR） |
| [CHANGELOG.md](CHANGELOG.md) | 変更履歴 |

## ライセンス

TODO(要確認): LICENSE ファイルがなく、ライセンスは定められていない。
