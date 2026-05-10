# 勤怠管理システムB

従業員の勤怠（出勤・退勤）を管理するWebアプリケーションです。プログラミングの学習過程で作成しました。

## 機能一覧

### 一般ユーザー
- ログイン / ログアウト
- アカウント作成・個人情報編集
- 勤怠表示（月単位）
- 出勤・退勤ボタン操作
- 勤怠編集（1ヶ月分一括編集）

### 管理者
- ユーザー一覧・検索（部分一致・ページネーション）
- 他ユーザーの勤怠表示・編集
- 他ユーザーの出勤・退勤ボタン操作
- 基本情報編集（基本時間・指定勤務時間の設定）
- ユーザー削除

## 技術スタック

| 項目 | 内容 |
|------|------|
| 言語 | Ruby 3.3.0 |
| フレームワーク | Ruby on Rails 7.1.6 |
| データベース（本番） | PostgreSQL（Neon） |
| データベース（開発） | MySQL |
| 認証 | Devise |
| CSSフレームワーク | Bootstrap 5 |
| ホスティング | Render |

## 本番環境

URL: https://kintai-system-b.onrender.com

| アカウント | メールアドレス | パスワード |
|------------|--------------|------------|
| 管理者 | admin@example.com | password |
| テスト | test@example.com | password |

## ローカル環境のセットアップ

```bash
# リポジトリをクローン
git clone https://github.com/NishiwakiTaichi/kintai_system_b.git
cd kintai_system_b

# gemをインストール
bundle install

# データベースを作成・マイグレーション・seedデータ投入
bin/rails db:create
bin/rails db:migrate
bin/rails db:seed

# サーバー起動
bin/rails server
```

ブラウザで `http://localhost:3000` を開いてください。
