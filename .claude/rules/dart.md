---
paths:
  - "mobile/**"
---

# Dart / Flutter 規約

## スコープ

本規約は `mobile/` 配下の Dart コードについて、アーキテクチャ（レイヤ・依存方向・状態の表現）と、機械検査で判定できないコーディングの判断基準を定義する。技術スタックの選定理由は `docs/tech-selection.md` が、画面の仕様は `docs/design-requirements.md` が定める。

以下は定義しない。

* 機械判定できる規約（命名の詳細、フォーマット、API の誤用）。「機械検査が担う範囲」に挙げるツールが担う
* 個々の画面の Provider 構成や具体的なファイル名。実装コードそのものが正となる

## アーキテクチャ規約

### レイヤと依存方向

UI（Widget）→ 状態（Riverpod Provider）→ API クライアント の一方向とする。

* Widget は Provider の watch と操作の呼び出しのみを行い、API クライアントを直接呼ばない
* API クライアントは Flutter にも Riverpod にも依存しない純粋 Dart とする。依存は http と標準ライブラリのみ
* 下位層から上位層への import を禁止する

API クライアントを純粋 Dart に保つのは、通信境界の検証を Flutter ランタイムなしの unit test で書けるようにするためである。

Flutter に依存しない判定・計算（日の境界の判定など）も、Widget や Provider の中に書かず純粋 Dart の関数として分離する。理由は同じくテスト方針（後述）による。

### ディレクトリ構成

feature-first とする。トップレベルを層（widgets / providers）で切らない。

```
mobile/lib/
  features/<feature>/   画面の Widget と、その画面が使う Provider
  api/                  API クライアントとリクエスト・レスポンス型
```

feature は画面のまとまり単位で切る。層で切らないのは、1つの画面の変更が1ディレクトリで閉じることを優先するためである。

feature 同士は import しない。複数の feature から参照される Provider・関数は feature の外の共有ディレクトリへ移す。feature 間に依存が生じると、変更の影響範囲がディレクトリ境界から読み取れなくなるためである。

### Provider の使い分け

| 状態 | 手段 |
|---|---|
| サーバーから取得する読み取りデータ | FutureProvider |
| サーバーへの更新操作を伴うデータ（補正、固定費の指定など） | AsyncNotifierProvider |
| 1つの Widget に閉じる一時状態（入力中の値、フォーカス） | StatefulWidget などの局所状態。Provider にしない |

一時状態を Provider にしないのは、画面の外から参照されない状態をグローバルなスコープに置くと、寿命の管理（破棄・リセット）だけが増えるためである。

非同期の3相（loading / error / data）は AsyncValue が表現する。自前の状態クラスに loading フラグや error フィールドを持ち込まない。

### 画面状態の表現

同時に成立しない排他的な画面状態（「今日」画面の実績未取得・回答前・結果 など）は、bool や nullable の組み合わせではなく sealed class で表現し、switch の網羅性検査に載せる。状態を追加・変更したときに、分岐の漏れをコンパイラが検出できるようにするためである。

このとき業務状態（sealed class）と通信状態（AsyncValue）は直交させる。「どの状態か」は取得済みデータから導出するものであり、「取得できたか」とは別の軸である。

### Riverpod の慣習

* Provider 名は `xxxProvider` サフィックスとする
* build メソッド内では `ref.watch`、コールバック内では `ref.read` を使う
* コード生成（riverpod_generator）は使わない。Provider 数が画面数程度にとどまる規模で、build_runner という常駐工程を持ち込む利点がないためである

## コーディング規約

### 機械検査が担う範囲

| ツール | 担う範囲 |
|---|---|
| flutter_lints | Effective Dart 準拠の静的検査 |
| riverpod_lint（custom_lint 経由） | Riverpod の誤用検出 |
| dart format | フォーマット |

これらで判定できる項目を本規約には書かない。決定論的に判定できる規約を新たに設けるときは、本文への追記ではなく lint ルールの追加で表現する（CLAUDE.md「制約とコンテキストの置き場所」）。

### テスト方針

* **unit test**: Flutter に依存しない判定・計算。アーキテクチャ規約が求める分離（純粋 Dart の関数、純粋 Dart の API クライアント）が前提となる
* **widget test**: 状態と表示の対応（排他的状態の出し分け、結果表示の構成要素）。Provider は override で差し替える

振り分けの基準は「レンダリング結果の検証が必要か」のみとする。ロジックの検証を widget test に寄せない。widget test は unit test より遅く、ロジックの回帰検出をそこへ寄せると検査全体が遅くなるためである。
