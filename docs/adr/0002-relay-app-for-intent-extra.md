# 0002. extra 付きのインテントを送る中継アプリにする

- ステータス: Accepted
- 日付: 2026-09-20（Git 管理を始めた日。判断の日付は記録がない）

## 背景（Context）

Notion AI を音声入力モードで開くには、アクション `notion.local.id.OPEN_NOTION_AI` に extra `input_mode=voice` を付ける必要がある。
一方、Nothing OS の電源ボタン2回押しの設定は、`Settings.Secure` の `nt_double_tap_power_data` に、パッケージ名とアクティビティ名だけを保持する形式で、extra を持てない。

```json
{"type":8,"app_type":8,"torch_type":4,
 "pkgName":"com.nothing.soundrecorder","info":"com.nothing.soundrecorder.MainActivity","uid":0}
```

## 決定内容（Decision）

extra 付きのインテントを送るだけのアプリを1つ挟む。アプリは画面を持たず（`Theme.NoDisplay`）、送信後すぐに終了する。

## 理由と検討した代替案（Consequences / Alternatives）

- 電源ボタン2回押しの設定からは、このアプリを選ぶだけで済む。同じアプリを、ランチャーとデジタルアシスタント枠（`ASSIST`）からも起動できる。
- Notion の非公開仕様に依存するため、Notion の更新で動かなくなる可能性がある。
- 検討した代替案: TODO(要確認)（記録がない）。
