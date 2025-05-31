# システムアーキテクチャについて

## 基本構成
### Backend
```
.
├── cmd/
│   └── server/              # サーバーのエントリーポイント
│       └── main.go
├── internal/                # 外部に公開しない内部実装
│   ├── adapters/            # 外部サービスとのアダプター (例: Google IDPクライアント)
│   ├── application/         # アプリケーションのビジネスロジック (ユースケース層)
│   │   ├── auth/
│   │   │   └── service.go
│   │   └── expense/
│   │       └── service.go
│   ├── domain/              # ドメインモデル、エンティティ、インターフェース定義
│   │   ├── user.go
│   │   ├── expense.go
│   │   └── repository.go    # リポジトリインターフェース
│   ├── infrastructure/      # インフラ関連 (DB接続、キャッシュクライアントなど)
│   │   ├── database/
│   │   │   └── postgres.go
│   │   └── cache/
│   │       └── redis.go
│   ├── interfaces/          # HTTPハンドラー (コントローラー層)
│   │   ├── http/
│   │   │   ├── router.go
│   │   │   ├── auth_handler.go
│   │   │   └── expense_handler.go
│   │   └── middleware/
│   │       ├── auth_middleware.go
│   │       ├── csrf_middleware.go
│   │       └── rate_limit_middleware.go
│   └── repository/          # リポジトリの実装 (DBアクセスコード)
│       ├── user_repository.go
│       └── expense_repository.go
│   └── util/                # ユーティリティ関数
│       └── jwt.go
│       └── error.go
├── pkg/                     # 汎用的なライブラリ (複数のプロジェクトで再利用可能なもの)
│   └── errors/              # カスタムエラーパッケージ
│   └── logger/              # ロギングパッケージ
│   └── index.html
└── go.mod
└── go.sum
```

### Frontend
```
.
├── public/                 # 静的ファイル (index.html など)
├── src/
│   ├── assets/             # 静的アセット (画像、アイコン、CSS変数など)
│   ├── components/         # 再利用可能なUIコンポーネント
│   │   ├── atoms/          # 最小単位のコンポーネント (ボタン, テキスト入力, アイコンなど)
│   │   ├── molecules/      # Atomを組み合わせたコンポーネント (フォームフィールド, ナビゲーションアイテムなど)
│   │   └── organisms/      # MoleculeやAtomを組み合わせた複雑なコンポーネント (ヘッダー, フッター, カードなど)
│   ├── contexts/           # React Context API を使用したグローバルな状態管理
│   ├── hooks/              # カスタムフック (ロジックの再利用)
│   │   ├── useAuth.ts      # 認証状態管理
│   │   ├── useApi.ts       # API通信ロジック
│   │   └── useForm.ts      # フォーム入力管理
│   ├── pages/              # アプリケーションの各ページコンポーネント (ルーティングに対応)
│   │   ├── HomePage.tsx
│   │   ├── LoginPage.tsx
│   │   ├── ExpenseListPage.tsx
│   │   └── NotFoundPage.tsx
│   ├── services/           # バックエンドAPIとの通信ロジック
│   │   ├── api.ts          # HTTPクライアントのインスタンス、共通設定
│   │   └── authService.ts  # 認証関連APIの呼び出し
│   │   └── expenseService.ts # 家計簿関連APIの呼び出し
│   ├── store/              # より複雑な状態管理 (Redux, Zustand, Recoil など)
│   │   ├── authStore.ts
│   │   └── expenseStore.ts
│   ├── types/              # TypeScriptの型定義
│   │   ├── auth.ts
│   │   ├── expense.ts
│   │   └── common.ts
│   ├── utils/              # 汎用的なユーティリティ関数
│   │   ├── dateUtils.ts
│   │   └── validationUtils.ts
│   ├── App.tsx             # ルートコンポーネント
│   ├── index.tsx           # エントリーポイント
│   └── react-app-env.d.ts  # TypeScript環境定義
└── package.json
```

## コーディング規約
TBD...
