---
paths:
  - "mobile/**"
---

# Dart / Flutter コーディング規約

## スコープ

本規約は `mobile/` 配下の Dart コードについて、機械検査で判定できないコーディングの判断基準と、機械検査が担う範囲の宣言を定義する。レイヤ・依存方向・状態の表現は `.claude/rules/architecture/dart.md` が定める。

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

## テスト方針

* **unit test**: Flutter に依存しない判定・計算。アーキテクチャ規約が求める分離（純粋 Dart の関数、純粋 Dart の API クライアント）が前提となる
* **widget test**: 状態と表示の対応（排他的状態の出し分け、結果表示の構成要素）。Provider は override で差し替える

振り分けの基準は「レンダリング結果の検証が必要か」のみとする。ロジックの検証を widget test に寄せない。widget test は unit test より遅く、ロジックの回帰検出をそこへ寄せると検査全体が遅くなるためである。
