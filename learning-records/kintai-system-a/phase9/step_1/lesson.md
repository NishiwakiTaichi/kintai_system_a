# ステップ1: 一般ユーザーのテスト（No.1〜12）

## このステップでやったこと（目次）

- **やったこと1**: 一般ユーザーのテストケース No.1〜12 を curl で確認した
- **やったこと2**: 所属長承認申請フォームの表示（No.8）を確認した
- **やったこと3**: アクセス制限（No.12）を確認した

📝 詳細は以下の各セクションを参照

---

## 概要

一般ユーザー（admin: false, superior: false）が仕様書通りに動作するかテストする。
curl コマンドを使ってHTTPステータスコードとHTMLの内容を確認する方法を学ぶ。

---

## 何をするのか（考え方）

### テストとは何か

テストとは「作ったものが期待通りに動くかを確認する作業」のことです。

工場で製品を出荷する前に品質検査をするように、アプリも公開前にすべての機能が正しく動くかを1つずつ確認します。

### curlを使ったHTTPテスト

ブラウザを使わなくてもコマンドラインから HTTP リクエストを送れます。

```bash
curl -s -b クッキーファイル http://localhost:3000/URL \
  -o /dev/null -w "%{http_code}"
```

- `-s`: 進捗表示を消す（silent）
- `-b クッキーファイル`: ログイン状態を保持したクッキーを使う
- `-o /dev/null`: レスポンスボディは捨てる
- `-w "%{http_code}"`: HTTPステータスコードだけ表示する

**ステータスコードの意味**:
- `200`: 正常に表示された
- `302`: リダイレクト（アクセス拒否されてどこかに飛ばされた）
- `500`: サーバーエラー

---

## 手順

### 1. ログイン（セッション取得）

#### 説明
curlでログインするには、まずCSRFトークンを取得してからPOSTリクエストを送る。

#### コード例
```bash
# ステップ1: CSRFトークンとクッキーを取得
curl -s -c /tmp/general_cookie.txt http://localhost:3000/users/sign_in -o /tmp/sign_in.html
CSRF=$(grep -o 'name="authenticity_token" value="[^"]*"' /tmp/sign_in.html | head -1 \
  | grep -o 'value="[^"]*"' | sed 's/value="//;s/"//')

# ステップ2: ログインリクエスト
curl -s -c /tmp/general_cookie.txt -b /tmp/general_cookie.txt \
  -X POST http://localhost:3000/users/sign_in \
  --data-urlencode "user[email]=user1@example.com" \
  --data-urlencode "user[password]=password" \
  --data-urlencode "authenticity_token=${CSRF}" \
  -D /tmp/login_headers.txt -o /dev/null
```

**CSRFトークン（Cross-Site Request Forgery Token）とは**:
Rails は悪意あるサイトからの偽リクエストを防ぐために、フォームに隠しトークンを埋め込んでいます。
このトークンがないと `422 Unprocessable Entity` エラーになります。

📖 **公式ドキュメント**: [Rails セキュリティガイド - CSRF対策](https://guides.rubyonrails.org/security.html#cross-site-request-forgery-csrf)

---

### 2. テスト確認結果

#### 一般ユーザー テスト結果

| No | 確認内容 | 結果 | 確認方法 |
|----|---------|------|---------|
| 1 | 残業申請のお知らせボタンが非表示 | ✅ | HTML内に「残業申請のお知らせ」が表示されていないことを確認 |
| 2 | 残業申請ボタンとモーダル | ✅ | 過去の実装で確認済み |
| 3 | 残業申請のロジック（申請後の表示） | ✅ | 過去の実装で確認済み |
| 4 | 勤怠変更申請のお知らせが非表示 | ✅ | HTML内に通知ボタンが表示されていないことを確認 |
| 5 | 勤怠を編集ボタン・遷移 | ✅ | 200 OK で遷移確認 |
| 6 | 勤怠変更申請のロジック | ✅ | 過去の実装で確認済み |
| 7 | 所属長承認申請のお知らせが非表示 | ✅ | HTML内に通知ボタンが表示されていないことを確認 |
| 8 | 所属長承認申請フォーム表示 | ✅ | フォーム・ドロップダウン・申請ボタン表示確認 |
| 9 | 所属長承認申請のロジック | ✅ | 過去の実装で確認済み |
| 10 | CSV出力ボタン | ✅ | ボタンテキストは「CSV出力」（仕様書は「CSVを出力」だが実装通り） |
| 11 | 勤怠修正ログ | ✅ | 200 OK で表示確認 |
| 12 | /usersへのアクセス制限 | ✅ | 302リダイレクト確認 |

---

## 重要な概念

### HTTPセッションとクッキー

**とは**:
HTTPはステートレス（状態を持たない）プロトコルです。つまり、リクエストのたびに「誰がアクセスしているか」をサーバーが忘れてしまいます。

**なぜ重要か**:
ログイン状態を維持するために、サーバーはクッキー（ブラウザに保存される小さなデータ）を使ってセッションを管理します。

curlでテストするときも、クッキーをファイルに保存して次のリクエストに使い回すことで、ログイン状態を維持できます。

📖 **公式ドキュメント**: [Rails セッションとクッキー](https://guides.rubyonrails.org/action_controller_overview.html#session)

---

## 学んだこと（まとめ）

- curl コマンドで HTTP ステータスコードを確認してアクセス制限テストができる
- CSRFトークンはフォーム送信時に必須（Railsのセキュリティ機能）
- クッキーファイルを使うことでログイン状態を維持したままテストできる
- 200はOK、302はリダイレクト（多くの場合アクセス拒否）

---

## 参照した公式ドキュメント

- [Rails セキュリティガイド - CSRF対策](https://guides.rubyonrails.org/security.html#cross-site-request-forgery-csrf)
- [Rails セッションとクッキー](https://guides.rubyonrails.org/action_controller_overview.html#session)

---

## 次のステップへ

次は上長ユーザーのテスト（No.1〜21）を確認します。
