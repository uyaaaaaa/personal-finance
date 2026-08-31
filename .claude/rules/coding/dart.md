---
paths:
  - "mobile/**"
---

# Dart / Flutter コーディング規約

## スコープ

本規約は `mobile/` 配下の Dart コードについて、機械検査で判定できない Dart 固有のコーディングの判断基準と、機械検査が担う範囲の宣言を定義する。言語によらない基準（命名・コメント・依存の追加）は `.claude/rules/coding/common.md` が、レイヤ・依存方向・状態の表現は `.claude/rules/architecture/dart.md` が定める。

## 機械検査が担う範囲

| ツール | 担う範囲 |
|---|---|
| flutter_lints | Effective Dart 準拠の静的検査 |
| riverpod_lint（custom_lint 経由） | Riverpod の誤用検出 |
| dart format | フォーマット |

これらで判定できる項目を本規約には書かない。決定論的に判定できる規約を新たに設けるときは、本文への追記ではなく lint ルールの追加で表現する（CLAUDE.md「制約とコンテキストの置き場所」）。

## Riverpod の慣習

* Provider 名は `xxxProvider` サフィックスとする
* build メソッド内では `ref.watch`、コールバック内では `ref.read` を使う
* コード生成（riverpod_generator）は使わない。Provider 数が画面数程度にとどまる規模で、build_runner という常駐工程を持ち込む利点がないためである

## 値の表現

境界での表現は `.claude/rules/architecture/api.md`「値の表現」が定める。アプリ内部では次に従う。

* 金額は `int`（円）で扱う。`double` にしない
* API から受け取った日時は UTC の `DateTime` として保持し、ローカルへの変換は表示の直前に行う。UTC とローカルの `DateTime` を同じ変数・同じフィールドに混在させない。Dart の `DateTime` は型でどちらかを区別しないため、変換点を1箇所に固定しないと二重変換に気づけないためである
* 「どの日か」はサーバーが返した日付をそのまま使い、端末側で日時から導出しない（`.claude/rules/architecture/api.md`「1日の境界」）

## エラーの扱い

* 通信の失敗・サーバーのエラーは例外として送出し、AsyncValue のエラー相へ載せる。Provider の中で握りつぶして空データに倒さない。失敗と「明細が0件」が同じ表示になると、捕捉漏れを確認するという明細一覧の役割（要求定義「明細への導線」）が成立しないためである
* 業務上ありうる分岐（回答前、明細が0件）は例外ではなく型で表す（`.claude/rules/architecture/dart.md`「画面状態の表現」）

## テスト方針

* **unit test**: Flutter に依存しない判定・計算。アーキテクチャ規約が求める分離（純粋 Dart の関数、純粋 Dart の API クライアント）が前提となる
* **widget test**: 状態と表示の対応（排他的状態の出し分け、結果表示の構成要素）。Provider は override で差し替える

振り分けの基準は「レンダリング結果の検証が必要か」のみとする。ロジックの検証を widget test に寄せない。widget test は unit test より遅く、ロジックの回帰検出をそこへ寄せると検査全体が遅くなるためである。
