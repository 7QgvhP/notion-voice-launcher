# 設計判断記録（ADR）

重要な設計判断を、1判断1ファイルで記録する。

## ファイル命名規則

`NNNN-短い題名.md`（`NNNN` は4桁の連番。題名は英小文字とハイフン）

## ステータス

| ステータス | 意味 |
|---|---|
| Proposed | 提案中 |
| Accepted | 採用済み |
| Deprecated | 廃止（後継なし） |
| Superseded | 別の ADR で置き換えられた（置き換えた ADR へのリンクを書く） |

## 運用

- 既存の ADR は書き換えない。判断を変えるときは新しい ADR を追加し、古い ADR のステータスを Superseded にする。

## 一覧

| 番号 | 題名 | ステータス | 日付 |
|---|---|---|---|
| [0001](0001-record-architecture-decisions.md) | ADR で設計判断を記録する | Accepted | 2026-11-15 |
| [0002](0002-relay-app-for-intent-extra.md) | extra 付きのインテントを送る中継アプリにする | Accepted | 2026-09-20 以前 |
| [0003](0003-build-without-gradle.md) | Gradle を使わず、SDK のツールを直接呼んでビルドする | Accepted | 2026-09-20 以前 |
| [0004](0004-version-source-in-build-script.md) | バージョンと SDK レベルの出典を `build.ps1` に一元化する | Accepted | 2026-09-20 以前 |
| [0005](0005-do-not-bypass-keyguard.md) | ロック解除を省略する方式を採用しない | Accepted | 2026-09-20 以前 |
| [0006](0006-auto-detect-toolchain.md) | ツールチェーンのバージョンを固定せず自動で探す | Accepted | 2026-09-20 以前 |

「2026-09-20 以前」は、Git での管理を始めた日（v1.1.4）より前に決めた判断。
