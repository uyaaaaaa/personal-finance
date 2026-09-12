---
paths:
  - "mobile/**"
---

# Dart / Flutter アーキテクチャ規約

## レイヤと依存方向

UI（Widget）→ 状態（Riverpod Provider）→ API クライアント の一方向とする。

* Widget は Provider の watch と操作の呼び出しのみを行い、API クライアントを直接呼ばない
* API クライアントは Flutter にも Riverpod にも依存しない純粋 Dart とする。依存は http と標準ライブラリのみ
* 下位層から上位層への import を禁止する

Flutter に依存しない判定・計算（日の境界の判定など）も、Widget や Provider の中に書かず純粋 Dart の関数として分離する。

## ディレクトリ構成

feature-first とする。トップレベルを層（widgets / providers）で切らない。

```
mobile/lib/
  features/<feature>/   画面の Widget と、その画面が使う Provider
  api/                  API クライアントとリクエスト・レスポンス型
```

feature は画面のまとまり単位で切る。層で切らないのは、1つの画面の変更が1ディレクトリで閉じることを優先するためである。
feature 同士の import は禁止。

