---
paths:
  - "mobile/**"
---

# Dart / Flutter コーディング規約

すべての原則は、Fluttter公式の [Guide to app architecture](https://docs.flutter.dev/app-architecture/guide) に従う。

## テスト方針

* **unit test**: Flutter に依存しない判定・計算。アーキテクチャ規約が求める分離（純粋 Dart の関数、純粋 Dart の API クライアント）が前提となる
* **widget test**: 状態と表示の対応。Provider は override で差し替える

振り分けの基準は「レンダリング結果の検証が必要か」のみとする。ロジックの検証を widget test に寄せない。
