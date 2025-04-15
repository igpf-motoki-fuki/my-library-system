## サービス概要
my library systemは、図書管理システムです。主に書籍情報や閲覧ユーザーの管理、一覧化などを行うWebアプリケーション部と、書籍情報を読み取るフロントシステム部に別れています。バーコードから書籍のJANコードを読み取り、国立国会図書館サーチAPIへリクエストを投げることで図書データが取得可能です。

現在はオンプレミス機上での動作を前提としていますが、将来的にはAWS上にWebアプリケーション部を配置し、フロントシステム部だけをオンプレ機に配置する構想を考えています。

## 機能要件
- 読み取った書籍データは原則、即時にWebアプリケーションに反映される
- 一度にAPIに送信できる件数は50件まで
- APIへの呼び出しはフロントシステム部で行うものとする。
- APIから取得したデータは一時的にフロントシステム部でキャッシュするが、webアプリケーション部に送信が完了したことが確認できた段階でアーカイブする。(アーカイブファイルを作成)
- アーカイブファイルは100件になったら古いものから順番に削除する。
## インフラ・アプリケーション構成
#### OS
- Ubuntu 24.04
#### ミドルウェア
- Kubernetes(Prometheus, Grafanaなどを含む)
- Docker
- MySQL8.0
- Ansible(必要に応じて)
#### アプリ
- Ruby on Rails: Webアプリケーションバックエンド
- Vue.js(Vuex): Webアプリケーションフロントエンド
- Dart: フロントシステム部ネイティブアプリ
#### CI/CD
- Github Actions

## データ構造
```mermaid
erDiagram
    Books ||--o{ Lendings : "has"
    Books ||--o{ BookNotes : "has"
    Users ||--o{ Lendings : "has"
    Books {
        bigint id PK
        string isbn
        string title
        string author
        string publisher
        date published_date
        string classification
        text description
        string status
        datetime created_at
        datetime updated_at
    }
    Users {
        bigint id PK
        string email
        string encrypted_password
        string name
        string role
        boolean active
        datetime created_at
        datetime updated_at
    }
    Lendings {
        bigint id PK
        bigint book_id FK
        bigint user_id FK
        datetime lending_date
        datetime returned_date
        string status
        datetime created_at
        datetime updated_at
    }
    BookNotes {
        bigint id PK
        bigint book_id FK
        string score
        string book_review
        datetime created_at
        datetime updated_at
    }
    CacheData {
        bigint id PK
        string key
        json value
        datetime expires_at
        datetime created_at
        datetime updated_at
    }
```

### テーブル説明

#### Books（書籍情報）
- `isbn`: 書籍のISBN番号
- `title`: 書籍のタイトル
- `author`: 著者名
- `publisher`: 出版社名
- `published_date`: 出版日
- `classification`: 分類（NDC等）
- `description`: 書籍の説明
- `status`: 書籍の状態（在庫中、貸出中、修理中など）

#### Users（ユーザー情報）
- `email`: メールアドレス（ログインID）
- `name`: ユーザー名
- `role`: 権限（管理者、一般ユーザーなど）
- `active`: アカウントの有効/無効状態

#### Lendings（貸出履歴）
- `book_id`: 貸出された書籍のID
- `user_id`: 借りたユーザーのID
- `lent_at`: 貸出日時
- `returned_at`: 返却日時
- `status`: 貸出状態（貸出中、返却済みなど）

#### BookNotes（本の備考）
- `book_id`: スキャンされた書籍のID
- `score`: 本に対する評価値(100点満点)
- `book_review`: 本の感想

#### CacheData（キャッシュデータ）
- `key`: キャッシュのキー
- `value`: キャッシュの値（JSON形式）
- `expires_at`: キャッシュの有効期限

## 開発環境のセットアップ

### 必要条件
- Docker
- Docker Compose
- Make（オプション）

### 環境構築手順

1. リポジトリのクローン
```bash
git clone [repository-url]
cd my_library_system
```

2. 環境変数の設定
```bash
cp .env.example .env
# .envファイルを編集して必要な環境変数を設定
```

3. 開発環境の起動
```bash
# 初回起動時
docker-compose build
docker-compose up -d

# データベースのセットアップ
docker-compose exec backend rails db:create
docker-compose exec backend rails db:migrate
docker-compose exec backend rails db:seed
```

4. アプリケーションへのアクセス
- バックエンドAPI: http://localhost:3000
- フロントエンド: http://localhost:8080

### 開発用コマンド

```bash
# ログの確認
docker-compose logs -f [service-name]

# コンテナへの接続
docker-compose exec [service-name] bash

# データベースのリセット
docker-compose exec backend rails db:reset

# テストの実行
docker-compose exec backend rails test
```

### トラブルシューティング

1. コンテナの再起動
```bash
docker-compose restart [service-name]
```

2. コンテナの再ビルド
```bash
docker-compose build [service-name]
docker-compose up -d [service-name]
```

3. ボリュームの削除（データベースをリセットする場合）
```bash
docker-compose down -v
```

## デプロイ手順
#### シークレット作成
```
kubectl create secret generic app-secrets \
  --from-literal=database-url='mysql2://root:password@mysql:3306/my_library_system_production' \
  --from-literal=redis-url='redis://redis:6379/1' \
  --from-literal=mysql-root-password='your-secure-password'
```
### アプリケーションのデプロイ

```
kubectl apply -k k8s/base
```

### DB migration

```
kubectl exec -it $(kubectl get pod -l component=backend -o jsonpath='{.items[0].metadata.name}') -- rails db:migrate
```

### kubernetes動作確認

```
kubectl get pods
kubectl get services
kubectl get ingress
```