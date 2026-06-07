# 勤怠管理システムA

従業員の勤怠（出勤・退勤）を管理するWebアプリケーションです。プログラミングの学習過程で作成しました。

## 機能一覧

### 一般ユーザー
- ログイン / ログアウト
- 勤怠表示（月単位）
- 出勤・退勤ボタン操作
- 残業申請（上長へ申請）
- 勤怠変更申請（上長へ申請）
- 所属長承認申請（上長へ申請）
- CSV出力（表示月の勤怠）
- 勤怠修正ログ確認（承認済み）

### 上長ユーザー
- 一般ユーザーの全機能
- 残業申請の承認・否認
- 勤怠変更申請の承認・否認
- 所属長承認申請の承認・否認

### 管理者
- ユーザー一覧・編集・削除
- CSVインポートによる一括ユーザー登録
- 出勤社員一覧の確認
- 拠点情報の追加・編集・削除
- 基本情報の更新

## 技術スタック

| 項目 | 内容 |
|------|------|
| 言語 | Ruby 3.3.0 |
| フレームワーク | Ruby on Rails 7.1.6 |
| データベース（本番） | PostgreSQL（Render） |
| データベース（開発） | MySQL |
| 認証 | Devise |
| CSSフレームワーク | Bootstrap 5 |
| ホスティング | Render |

## 本番環境

URL: https://kintai-system-a.onrender.com

| アカウント | メールアドレス | パスワード |
|------------|--------------|------------|
| 管理者 | admin@example.com | password |
| 上長 A | superior1@example.com | password |
| 上長 B | superior2@example.com | password |
| 一般社員 | user1@example.com | password |

## ローカル環境のセットアップ

```bash
# リポジトリをクローン
git clone https://github.com/NishiwakiTaichi/kintai_system_a.git
cd kintai_system_a/rails

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
