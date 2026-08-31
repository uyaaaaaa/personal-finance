---
paths:
  - "mobile/**"
---

# Dart / Flutter アーキテクチャ規約

## スコープ

本規約は `mobile/` 配下の Dart コードのアーキテクチャ（レイヤ・依存方向・ディレクトリ構成・状態の表現）を定義する。

個々の画面の Provider 構成や具体的なファイル名は定義しない。実装コードそのものが正となる。

## レイヤと依存方向

UI（Widget）→ 状態（Riverpod Provider）→ API クライアント の一方向とする。

* Widget は Provider の watch と操作の呼び出しのみを行い、API クライアントを直接呼ばない
* 下位層から上位層への import を禁止する

Flutter に依存しない判定・計算（入力値の検証、表示用の整形など）は、Widget や Provider の中に書かず純粋 Dart の関数として分離する。Flutter ランタイムを起動しない unit test で検証できる。

## ディレクトリ構成

feature-first とする。トップレベルを層（widgets / providers）で切らない。

```
mobile/lib/
  features/<feature>/   画面の Widget と、その画面に閉じる Provider
  core/                 複数の feature が使う Provider・関数と、画面に属さない端末機能（ローカル通知、サインイン状態、HTTP の interceptor）
  api/                  OpenAPI 仕様から生成した API クライアント
```

feature は画面のまとまり単位で切る。層で切らないのは、1つの画面の変更が1ディレクトリで閉じることを優先するためである。

feature 同士は import しない。複数の feature から参照される Provider・関数は `core/` へ移す。feature 間に依存が生じると、変更の影響範囲がディレクトリ境界から読み取れなくなる。

`core/` は features を import しない。

## API クライアント

* `api/` はサーバーが出力する OpenAPI 仕様からの生成物とし、手で編集しない
* `features/` と `core/` は、HTTP を `api/` の生成クライアント経由でのみ行う。dio を直接 import しない。通信経路が生成物の外に増えると、契約が保証される範囲が読み取れなくなる
* 生成クライアントは Flutter・Riverpod・firebase_auth に依存しない。依存すべき対象が生成物の出力に現れた場合は、呼び出し側で包むのではなく生成設定を直す

## 認証トークンの受け渡し

* ID トークンの付与は、`core/` が定義した HTTP の interceptor が行う。Provider や Widget が Authorization ヘッダを組み立てない
* トークン失効（サーバーが認証エラーを返した場合）も同じ interceptor が受け、`core/` のサインイン状態へ倒す。画面ごとに分岐を置くと、扱い漏れた画面だけが空表示になり、原因が失効であることも読み取れない
* interceptor は生成クライアントが持つ HTTP インスタンスへ注入する。生成物そのものは編集しない

「認証が要るかどうか」は呼び出しごとの判断ではなく、クライアント全体の性質として固定する。アプリからの通信はすべてトークン付きとする。

## Provider の使い分け

| 状態 | 手段 |
|---|---|
| サーバーから取得する読み取りデータ | FutureProvider |
| サーバーへの更新操作を伴うデータ（補正、固定費の指定など） | AsyncNotifierProvider |
| 1つの Widget に閉じる一時状態（入力中の値、フォーカス） | StatefulWidget などの局所状態。Provider にしない |

画面の外から参照されない状態をグローバルなスコープに置くと、寿命の管理（破棄・リセット）だけが増える。

非同期の3相（loading / error / data）は AsyncValue が表現する。自前の状態クラスに loading フラグや error フィールドを持ち込まない。

## 画面状態の表現

同時に成立しない排他的な画面状態（「今日」画面の実績未取得・回答前・結果 など）は、bool や nullable の組み合わせではなく sealed class で表現し、switch の網羅性検査に載せる。

このとき業務状態（sealed class）と通信状態（AsyncValue）は直交させる。「どの状態か」は取得済みデータから導出するものであり、「取得できたか」とは別の軸である。

## 機械検査で固定する範囲

本規約のうち決定論的に判定できる項目は、文章ではなく検査で固定する（CLAUDE.md「制約とコンテキストの置き場所」）。

| 対象 | 固定の手段 |
|---|---|
| feature 間の import と、`core/` から `features/` への import | `lib/` の import を走査するテスト |
| `features/` と `core/` が HTTP ライブラリを直接 import しないこと | 同上 |
| 排他的状態の分岐漏れ | sealed class に対する switch の網羅性検査 |
| Provider の誤用 | riverpod_lint |
| 生成クライアントと OpenAPI 仕様の一致 | 再生成して差分が空であること |

依存方向の検査は、`mobile/` に最初のコードを置く時点で同時に用意する。検査を伴わない依存規約は、セッションをまたぐと守られない。
