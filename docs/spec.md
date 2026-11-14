# 仕様

## 目的とスコープ

Nothing Phone (4a) のジェスチャー操作から、Notion AI を音声入力モードの状態で直接開く。

### やること
- 起動されたら、Notion AI を音声入力モード（録音バーが出た状態）で開くインテントを送る。
- 電源ボタン2回押し、ランチャー、デジタルアシスタント枠のどれから起動されても、同じ動作をする。

### やらないこと
- 画面の表示（設定画面も含め、UI を持たない）。
- 画面ロックの解除（認証）の省略。理由は [ADR 0005](adr/0005-do-not-bypass-keyguard.md)。
- Notion 以外のアプリの起動。

## 機能一覧

### Notion AI を音声入力モードで開く
起動と同時に、次のインテントを送り、自身は終了する。

| 項目 | 値 |
|---|---|
| アクション | `notion.local.id.OPEN_NOTION_AI` |
| 送り先のパッケージ | `notion.id` |
| 受け口（Notion 側） | `notion.local.id.MainActivity`（`category.DEFAULT` 付きで exported） |
| extra | `input_mode` = `voice`（String） |
| フラグ | `FLAG_ACTIVITY_NEW_TASK`（Notion を独立したタスクの最前面に出す） |

extra を省略すると、Notion は AI チャット画面（テキスト入力）で開く。`input_mode=voice` を付けると、録音バーが出た状態で開く。

### 起動の経路
- ランチャー（`MAIN` / `LAUNCHER`）: アプリ一覧と、電源ボタン2回押しの選択肢に表示される。表示名は「Notion 音声入力」。
- デジタルアシスタント（`android.intent.action.ASSIST`）: Android の既定のデジタルアシスタントに設定すると、Nothing Ear (open) の「ボイスアシスタント」ジェスチャーから起動できる。

### 画面ロック中の起動
ロック中に起動された場合、システムによってロック解除まで保留され、解除された時点で Notion が音声入力モードで開く。

## 入出力とデータ形式

- 入力: 起動インテント（内容は参照しない）。
- 出力: 上記のインテント。データの保存や通信は行わない（`android:allowBackup="false"`）。

## 制約条件

- Android 8.0（API 26）以上。targetSdk は 35。
- Notion アプリ（パッケージ `notion.id`）がインストールされていること。Android 11 以降でパッケージを解決するため、マニフェストで `<queries>` を宣言している。
- アクション名と extra は Notion の非公開仕様で、Notion アプリの更新で動かなくなる可能性がある。
- 検証時の Notion のバージョンでは、コールドスタート・ウォームスタートの両方で音声入力モードに入ることを確認済み（TODO(要確認): 検証した Notion のバージョンは記録がない）。
- 最近使ったアプリの一覧には表示されない（`excludeFromRecents`、`noHistory`）。

## エラー時の挙動

- Notion が見つからない（未インストール、または対応していないバージョン）場合は、「Notion アプリが見つかりませんでした」をトーストで表示して終了する。
