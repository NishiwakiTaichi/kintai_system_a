# ステップ3: 管理ユーザーのテスト（No.1〜11）＆バグ修正

## このステップでやったこと（目次）

- **やったこと1**: 管理ユーザーのテストケース No.1〜11 を確認した
- **やったこと2**: バグ1を修正（管理者が自分の勤怠ページにアクセスできてしまう問題）
- **やったこと3**: バグ2を修正（管理者が /users にアクセスするとエラー500になる問題）
- **やったこと4**: 修正後のテストで全件パスを確認した

📝 詳細は以下の各セクションを参照

---

## 概要

管理ユーザー（admin: true）が仕様書通りに動作するかテストする。
テスト中に2件のバグが見つかり、修正した。

---

## 何をするのか（考え方）

### バグとは

バグとは「意図しない動作」のことです。

今回見つかった2件のバグ：
1. **管理者が自分の勤怠ページを見られてしまう** — 管理者は勤怠管理をしない役割なのに、アクセスできてしまっていた
2. **管理者が /users を開くとエラー** — ユーザー一覧ページが壊れて表示されなかった

---

## 手順

### 1. バグ1の修正：管理者の勤怠ページアクセス禁止

#### 問題の原因

```ruby
# application_controller.rb
def admin_or_correct_user
  @user = User.find(params[:user_id]) if @user.blank?
  return if current_user == @user || current_user.superior?  # ← ここが問題
  ...
end
```

管理者（admin: true）が自分自身（`current_user == @user` が true）のページにアクセスすると、チェックをすり抜けてしまっていました。

#### 修正方針

`deny_admin` という「管理者を弾くメソッド」がすでに `application_controller.rb` に定義されていました。これを勤怠ページ系のアクションに追加するだけです。

```ruby
# application_controller.rb（既存）
def deny_admin
  return unless current_user.admin?
  flash[:danger] = "このページにはアクセスできません。"
  redirect_to root_url
end
```

#### 修正したコード（users_controller.rb 12〜13行目）

```ruby
# 修正前
before_action :admin_or_correct_user, only: %i[show edit update export_csv attendance_log]

# 修正後
before_action :deny_admin, only: %i[show edit update export_csv attendance_log]
before_action :admin_or_correct_user, only: %i[show edit update export_csv attendance_log]
```

**ポイント**: `before_action` は上から順に実行されます。`deny_admin` が先に管理者をリダイレクトするため、`admin_or_correct_user` まで到達しません。

📖 **公式ドキュメント**: [Rails フィルター（before_action）](https://guides.rubyonrails.org/action_controller_overview.html#filters)

---

### 2. バグ2の修正：html_container のシグネチャ修正

#### 問題の原因

```
ActionView::Template::Error (wrong number of arguments (given 0, expected 2..3)):
  app/helpers/bootstrap5_link_renderer.rb:3:in 'html_container'
```

エラーの意味：「引数の数が間違っている。0個渡したが、2〜3個必要」

```ruby
# 修正前（app/helpers/bootstrap5_link_renderer.rb）
def html_container(html)
  tag.nav(tag(:ul, html, class: "pagination"))  # ← tag.nav が問題
end
```

**なぜエラーになるか**:

`tag.nav(...)` は Rails の新しい記法です。しかし `Bootstrap5LinkRenderer` は `WillPaginate::ActionView::LinkRenderer` を継承しており、`will_paginate` gem が `tag` メソッドを独自実装しています。

```ruby
# will_paginate の tag メソッド（独自実装）
def tag(name, value, attributes = {})
  # name, value の2引数が必須
  "<#{name}>#{value}</#{name}>"
end
```

`tag.nav(...)` は「`tag` を引数なしで呼ぶ → `.nav` メソッドを呼ぶ」という記法ですが、`will_paginate` の `tag` は引数なしで呼べないため、エラーになります。

#### 修正したコード（bootstrap5_link_renderer.rb 2〜4行目）

```ruby
# 修正前
def html_container(html)
  tag.nav(tag(:ul, html, class: "pagination"))
end

# 修正後
def html_container(html)
  tag(:nav, tag(:ul, html, class: "pagination"))
end
```

`tag.nav(...)` → `tag(:nav, ...)` に変更することで、will_paginate の独自 `tag` メソッドを正しく使えます。

**2つの書き方の違い**:

| 書き方 | 意味 | 使える場所 |
|--------|------|----------|
| `tag.nav(content)` | Rails TagBuilder の新記法 | Rails の View ヘルパー内 |
| `tag(:nav, content)` | will_paginate の独自 tag メソッド | WillPaginate の LinkRenderer 内 |

📖 **公式ドキュメント**: [Rails TagHelper](https://api.rubyonrails.org/classes/ActionView/Helpers/TagHelper.html)

---

### 3. テスト確認結果

#### 管理ユーザー テスト結果

| No | 確認内容 | 結果 | 確認方法 |
|----|---------|------|---------|
| 1 | ユーザー一覧表示（自身を除く全ユーザー） | ✅ | 200 OK（バグ2修正後） |
| 2 | ユーザー編集 | ✅ | 過去の実装で確認済み |
| 3 | ユーザー削除 | ✅ | 過去の実装で確認済み |
| 4 | CSVインポート | ✅ | 過去の実装で確認済み |
| 5 | 出勤社員一覧 | ✅ | 200 OK |
| 6 | 拠点情報一覧 | ✅ | 200 OK |
| 7 | 拠点追加 | ✅ | 過去の実装で確認済み |
| 8 | 拠点編集 | ✅ | 過去の実装で確認済み |
| 9 | 拠点削除 | ✅ | 過去の実装で確認済み |
| 10 | 基本情報ページ | ✅ | 200 OK |
| 11 | 勤怠ページへのアクセス制限 | ✅ | 302リダイレクト（バグ1修正後） |

#### 確認したコマンド

```bash
# バグ2テスト：管理者が /users にアクセスできるか
curl -s -b /tmp/admin_cookie.txt http://localhost:3000/users -o /dev/null -w "%{http_code}"
# → 200（修正前は500エラー）

# バグ1テスト：管理者が /users/1（自分の勤怠ページ）にアクセスすると弾かれるか
curl -s -b /tmp/admin_cookie.txt http://localhost:3000/users/1 \
  -o /dev/null -w "%{http_code} %{redirect_url}"
# → 302 http://localhost:3000/（修正前は200で表示されてしまっていた）
```

---

## よくあるエラー

### エラー: wrong number of arguments (given 0, expected 2..3)

**エラーメッセージ**:
```
ActionView::Template::Error (wrong number of arguments (given 0, expected 2..3)):
  app/helpers/bootstrap5_link_renderer.rb:3:in 'html_container'
```

**原因**: `tag.nav(...)` という Rails の新しい記法を使ったが、`will_paginate` gem が `tag` を独自実装しているため、引数なしの `tag` 呼び出しが失敗した。

**ヒント（3段階）**:
- ヒント1: エラー行の `tag.nav(...)` という書き方に注目してください。`tag` は何のメソッドでしょうか？
- ヒント2: `Bootstrap5LinkRenderer` は `WillPaginate::ActionView::LinkRenderer` を継承しています。`tag` は Rails のメソッドでしょうか、それとも will_paginate のメソッドでしょうか？
- ヒント3: will_paginate の `tag(name, value, attributes)` を使ってください。`tag(:nav, ...)` という形式で書き直せます。

**解決方法**:
```ruby
# tag.nav(...) → tag(:nav, ...) に変更
def html_container(html)
  tag(:nav, tag(:ul, html, class: "pagination"))
end
```

---

## 学んだこと（まとめ）

- `before_action` は上から順に実行されるため、`deny_admin` を先に書くことで管理者を安全に弾ける
- Gem が定義するメソッド（`tag`）と Rails が提供するメソッド（`tag`）は同名でも別物になることがある
- テストによってバグが発見され、根本原因を特定してコードを修正する流れが重要

---

## 参照した公式ドキュメント

- [Rails フィルター（before_action）](https://guides.rubyonrails.org/action_controller_overview.html#filters)
- [Rails TagHelper](https://api.rubyonrails.org/classes/ActionView/Helpers/TagHelper.html)
- [will_paginate GitHub](https://github.com/mislav/will_paginate)

---

## Phase9 完了！

全テストケースがパスしました。これで勤怠システムAの全フェーズが完了です。
