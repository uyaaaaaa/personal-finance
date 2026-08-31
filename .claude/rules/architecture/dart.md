---
paths:
  - "mobile/**"
---

# Dart / Flutter アーキテクチャ規約

## スコープ

本規約は `mobile/` 配下の Dart コードのアーキテクチャ（レイヤ・依存方向・ディレクトリ構成・状態の表現）を定義する。コーディングの判断基準は `.claude/rules/coding/dart.md` が、技術スタックの選定理由は `docs/tech-selection.md` が、画面の仕様は `docs/design-requirements.md` が定める。

個々の画面の Provider 構成や具体的なファイル名は定義しない。実装コードそのものが正となる。

## レイヤと依存方向

UI（Widget）→ 状態（Riverpod Provider）→ API クライアント の一方向とする。

* Widget は Provider の watch と操作の呼び出しのみを行い、API クライアントを直接呼ばない
* API クライアントは Flutter にも Riverpod にも依存しない純粋 Dart とする。依存は http と標準ライブラリのみ
* 下位層から上位層への import を禁止する

API クライアントを純粋 Dart に保つのは、通信境界の検証を Flutter ランタイムなしの unit test で書けるようにするためである。

Flutter に依存しない判定・計算（日の境界の判定など）も、Widget や Provider の中に書かず純粋 Dart の関数として分離する。理由は同じくテスト方針（`.claude/rules/coding/dart.md`）による。

## ディレクトリ構成

feature-first とする。トップレベルを層（widgets / providers）で切らない。

```
mobile/lib/
  features/<feature>/   画面の Widget と、その画面が使う Provider
  api/                  API クライアントとリクエスト・レスポンス型
```

feature は画面のまとまり単位で切る。層で切らないのは、1つの画面の変更が1ディレクトリで閉じることを優先するためである。

feature 同士は import しない。複数の feature から参照される Provider・関数は feature の外の共有ディレクトリへ移す。feature 間に依存が生じると、変更の影響範囲がディレクトリ境界から読み取れなくなるためである。

## Provider の使い分け

| 状態 | 手段 |
|---|---|
| サーバーから取得する読み取りデータ | FutureProvider |
| サーバーへの更新操作を伴うデータ（補正、固定費の指定など） | AsyncNotifierProvider |
| 1つの Widget に閉じる一時状態（入力中の値、フォーカス） | StatefulWidget などの局所状態。Provider にしない |

一時状態を Provider にしないのは、画面の外から参照されない状態をグローバルなスコープに置くと、寿命の管理（破棄・リセット）だけが増えるためである。

非同期の3相（loading / error / data）は AsyncValue が表現する。自前の状態クラスに loading フラグや error フィールドを持ち込まない。

## 画面状態の表現

同時に成立しない排他的な画面状態（「今日」画面の実績未取得・回答前・結果 など）は、bool や nullable の組み合わせではなく sealed class で表現し、switch の網羅性検査に載せる。状態を追加・変更したときに、分岐の漏れをコンパイラが検出できるようにするためである。

このとき業務状態（sealed class）と通信状態（AsyncValue）は直交させる。「どの状態か」は取得済みデータから導出するものであり、「取得できたか」とは別の軸である。
