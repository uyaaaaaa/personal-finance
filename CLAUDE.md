# personal-finance

家計簿アプリケーション。実装コードは未着手である。git 履歴に残る過去実装（Go + Next.js + docker-compose）は現在の設計と無関係であり、既存実装として扱わない。参照はユーザーが明示的に指示した場合に限る。

## 索引

| 場所 | 定めるもの |
|---|---|
| `docs/requirements.md` | 目的、対象ユーザー、提供する体験、初期フェーズの検証設計 |
| `docs/design-requirements.md` | 画面の一覧・構成要素・状態・遷移、通知の挙動、視覚デザインの方向性 |
| `docs/design-guideline.md` | 視覚デザインと画面実装のガードレール（逸脱を判定するための禁止事項） |
| `docs/tech-selection.md` | 技術スタックと外部サービスの選定、およびその理由 |
| `.claude/rules/coding/common.md` | 言語によらないコーディングの判断基準と、`mobile/` と `server/` の双方にまたがる決定 |
| `.claude/rules/coding/dart.md` | Dart 固有のコーディングの判断基準 |
| `.claude/rules/coding/typescript.md` | TypeScript 固有のコーディングの判断基準 |
| `.claude/rules/architecture/dart.md` | `mobile/` のレイヤ・依存方向・ディレクトリ構成・状態の表現 |
| `.claude/rules/architecture/typescript.md` | `server/` のディレクトリ責務・依存方向・不変条件 |
| `.claude/skills/documentation/SKILL.md` | すべての `*.md` の置き場所の判定と記述規約 |
| `scripts/check` | 全検査の集約 |
| `.github/repo-settings.sh` | GitHub 側の設定の正。実行で反映する |

`docs/` は要求定義を頂点とする。デザイン要件定義と技術選定が要求定義を受け、デザインガイドラインがデザイン要件定義を受ける。

API のリクエスト・レスポンスの構造と、そこに現れる値の表現を定めるドキュメントは持たない。`server/` の zod スキーマが唯一の正であり、そこから生成された OpenAPI 仕様と Dart クライアントが従う。

## 全セッションの前提

- 作業完了は `./scripts/check` の実行結果で判断する。検査の追加先も文書ではなくこのスクリプトである
- public リポジトリであり、一度コミットした内容は取り消せない。家計の実データを作業ツリーに置かない。実データか否かは機械判定できず、hooks では防げない
- クローン直後に `git config core.hooksPath .githooks` を実行する。設定しない限り `.githooks/` は動作しない
