# personal-finance

家計簿アプリケーション。実装コードは未着手である。

## 前提

git 履歴に残る過去実装（Go + Next.js + docker-compose）は現在の設計と無関係である。
既存実装として扱わず、「既存コードに合わせる」判断の根拠にしない。参照はユーザーが明示的に指示した場合に限る。

## ドキュメント

各ドキュメントが定めるものを次に示す。ドキュメント同士の関係を記すのは本節のみとし、各ドキュメントには書かない。

| ドキュメント | 定めるもの |
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
| `.claude/skills/documentation/SKILL.md` | すべての `*.md` の記述規約 |

`docs/` は要求定義を頂点とする。デザイン要件定義と技術選定が要求定義を受け、デザインガイドラインがデザイン要件定義を受ける。`.claude/rules/` に上下関係はなく、`paths` にマッチしたものがすべて適用される。

API のリクエスト・レスポンスの構造と、そこに現れる値の表現を定めるドキュメントは持たない。`server/` の zod スキーマが唯一の正であり、そこから生成された OpenAPI 仕様と Dart クライアントが従う。

## 制約とコンテキストの置き場所

- 決定論的に判定できる制約は、文章ではなく型・スキーマ・lint・テスト・CI・hooks で表現する。文章の規約は機械検証できず、遵守がセッションごとに揺れるため。
- 文章で残すのは機械判定できない事項（設計意図、判断基準）に限る。置き場所はカテゴリ単位で切り、常時ロードされる範囲を最小にする。
  - 特定の作業のときだけ必要 → `.claude/skills/<name>/SKILL.md`（依頼内容に応じてオンデマンドでロード）
  - 特定のファイル群を触るときだけ必要 → `paths` フロントマター付きの `.claude/rules/<category>.md`
  - どちらにも絞れない → このファイル。`paths` なしの `.claude/rules/` は CLAUDE.md と同じく常時ロードされるため、置き場所として使わない。
- 作業完了は `./scripts/check` の実行結果をもって判断する。検査を追加するときは、文書ではなくこのスクリプトへ加える。

## リポジトリ運用

- git hooks はクローンごとに有効化する。設定しない限り `.githooks/` は動作しない。

  ```
  git config core.hooksPath .githooks
  ```

- GitHub 側の設定は `.github/repo-settings.sh` と `.github/ruleset-main.json` を正とし、その実行で反映する。管理画面での直接編集はスクリプトと乖離するため行わない。
- public リポジトリであり、一度コミットした内容は取り消せない。家計の実データを作業ツリーに置かない。実データか否かは機械判定できず、hooks では防げない。
