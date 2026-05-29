# ステップ3: 勤怠修正ログページの実装

## このステップでやったこと（目次）

- **やったこと1**: `attendance_log` アクションをコントローラーに追加した
- **やったこと2**: ルーティングに `get :attendance_log` を追加した
- **やったこと3**: `attendance_log.html.erb` ビューを新規作成した
- **やったこと4**: show.html.erb の修正ログボタンのリンクを実際のパスに変更した

📝 詳細は以下の各セクションを参照

---

## 概要
「勤怠修正ログ（承認済）」ボタンを押すと別ページへ遷移し、承認済みの勤怠変更履歴を一覧表示する機能を実装した。年・月フィルター付き。同じ日付を複数回変更した場合は「最初の変更前 → 最後の変更後」を1行にまとめて表示する。

---

## 確認した仕様書

| ファイル | タブ名 | 確認内容 |
|---------|--------|---------|
| `docs/spec/test_cases.md` | 「テストケース一覧」 | 一般ユーザー No.11、上長ユーザー No.20 |
| `docs/spec/ui_rules.md` | 「勤怠修正ログ（承認済）について」 | 複数回変更時のルール・表示列 |

---

## 手順

### 1. ルーティングの追加（`config/routes.rb`）

```ruby
member do
  get :export_csv
  get :attendance_log  # 追加
end
```

`member do` の中に書くことで `attendance_log_user_path(@user)` が使えるようになる。

---

### 2. コントローラーの変更（`app/controllers/users_controller.rb`）

#### 9〜10行目: `before_action :set_user` への追加

```ruby
before_action :set_user, only: %i[
  show edit update destroy edit_basic_info update_basic_info export_csv attendance_log
]
```

- `attendance_log` を追加。アクション実行前に `@user` が自動でセットされる

#### 12行目: `before_action :admin_or_correct_user` への追加

```ruby
before_action :admin_or_correct_user, only: %i[show edit update export_csv attendance_log]
```

- 本人か管理者だけアクセスできるセキュリティチェック

#### 80〜83行目: `attendance_log` アクション本体

```ruby
def attendance_log
  logs = fetch_approved_change_logs
  @attendance_logs = build_attendance_log_rows(logs)
end
```

- 81行目: `fetch_approved_change_logs` でDBからデータ取得
- 82行目: `build_attendance_log_rows` で表示用ハッシュの配列に加工して `@attendance_logs` に代入

**ポイント: なぜメソッドを分けるのか？**
処理を全部アクションの中に書くと長くなる。「何をしているか」を名前のついたメソッドに切り出すと、アクションを読んだだけで意図が伝わる。これは**自分で定義したメソッド**（Railsが用意したものではない）。

#### 131〜139行目: `fetch_approved_change_logs`（自作プライベートメソッド）

```ruby
def fetch_approved_change_logs
  logs = @user.attendance_change_applications
              .where(status: "承認済")
              .includes(:attendance, :supervisor)
  return logs unless params[:year].present? && params[:month].present?

  start_date = Date.new(params[:year].to_i, params[:month].to_i, 1)
  logs.joins(:attendance).where(attendances: { worked_on: start_date..start_date.end_of_month })
end
```

- 132〜134行目: `@user` の承認済み申請を全件取得
- 135行目: 早期リターン — 年・月パラメーターがなければそのまま返す
- 137行目: `Date.new(年, 月, 1)` で対象月の1日を生成
- 138行目: `attendances` テーブルを結合して日付で絞り込む

#### 142〜158行目: `build_attendance_log_rows`（自作プライベートメソッド）

```ruby
def build_attendance_log_rows(logs)
  rows = logs.group_by(&:attendance_id).map do |_id, grouped|
    sorted = grouped.sort_by(&:created_at)
    first  = sorted.first
    last   = sorted.last
    {
      worked_on: first.attendance.worked_on,
      before_started_at: first.before_started_at,
      before_finished_at: first.before_finished_at,
      after_started_at: last.after_started_at,
      after_finished_at: last.after_finished_at,
      supervisor_name: last.supervisor.name,
      approved_at: last.updated_at
    }
  end
  rows.sort_by { |log| log[:worked_on] }
end
```

- 143行目: `group_by(&:attendance_id)` — 同じ勤怠レコードへの申請をグループにまとめる
- 144行目: グループ内を `created_at` で昇順ソート
- 145行目: `first` = 最初の申請（「変更前」の出典）
- 146行目: `last` = 最後の申請（「変更後」の出典）
- 148〜150行目: `before_*` は `first` から取得 → 仕様「最初の変更前時刻」
- 151〜152行目: `after_*` は `last` から取得 → 仕様「最後の変更後時刻」
- 157行目: `worked_on` で昇順ソートして日付順に並べる

**データの変化イメージ（同じ日付に3回変更した場合）**

```
加工前（logs の中身）:
  id:1  attendance_id:10  before: 10:00  after: 11:00
  id:2  attendance_id:10  before: 11:00  after: 12:00
  id:3  attendance_id:10  before: 12:00  after: 13:00

加工後（@attendance_logs の中身）:
  { worked_on: 2/1, before_started_at: 10:00, after_started_at: 13:00, ... }
```

3件 → 1件のハッシュにまとまる。これが仕様の「最初の変更前 → 最後の変更後を1行で表示」。

---

### 3. ビューの作成（`app/views/users/attendance_log.html.erb`）

#### 6行目: フォームの定義

```erb
<%= form_with url: attendance_log_user_path(@user), method: :get, local: true do |f| %>
```

- `method: :get` — URLに `?year=2026&month=5` が付く形式。ブックマークや戻るボタンで再現できる
- `local: true` — 通常のHTTPリクエスト（同期通信）で送信する。デフォルトはAjax（非同期）になるため明示的に指定
- `do |f|` — `f` はフォームビルダーオブジェクト（フォーム部品を作る道具箱）

**フォームビルダーオブジェクトとは？**
`form_with` が自動で作って渡してくれる道具箱。`f.select`・`f.label`・`f.submit` などのメソッドを使うことで、URLやCSRFトークンと紐づいたHTMLが自動生成される（Railsが用意したメソッド）。

#### 13〜16行目: 年のセレクトボックス

```erb
<%= f.select :year,
             options_for_select((Date.current.year - 3..Date.current.year).map { |y| [y, y] }, params[:year]&.to_i),
             { include_blank: true },
             class: "form-select form-select-sm", style: "width: auto;" %>
```

- 14行目: `(Date.current.year - 3..Date.current.year)` — 今年から3年前まで選択肢を生成（仕様書に範囲指定なし、実装時の判断）
- 14行目: 第2引数 `params[:year]&.to_i` — 現在選択中の年をセレクトボックスで保持する

#### 43〜53行目: テーブルの行出力

```erb
<% @attendance_logs.each do |log| %>
  <tr>
    <td><%= log[:worked_on].strftime("%Y-%m-%d") %></td>
    <td><%= log[:before_started_at]&.strftime("%H:%M") %></td>
    ...
  </tr>
<% end %>
```

- 43行目: `@attendance_logs` はハッシュの配列なので `log[:キー名]` でアクセス
- 46〜49行目: `&.strftime` — nil（変更前が空の日）でもエラーにならない

---

## 重要な概念

### 早期リターン（return unless）

**とは**: 条件を満たさないときに即座に返す書き方。

```ruby
# 早期リターンなし
def fetch_logs
  logs = ...
  if params[:year].present? && params[:month].present?
    # 絞り込み処理
  end
  logs
end

# 早期リターンあり（ネストが浅くなる）
def fetch_logs
  logs = ...
  return logs unless params[:year].present? && params[:month].present?
  # 絞り込み処理
end
```

条件に合わないケースを先に弾くことでコードの読みやすさが上がる。

### group_by

**とは**: 配列の要素をキーでグループ分けするRubyのメソッド。

```ruby
[1, 2, 3, 4].group_by { |n| n.even? }
# => { true => [2, 4], false => [1, 3] }
```

📖 **公式ドキュメント**: [Ruby group_by](https://docs.ruby-lang.org/ja/latest/method/Enumerable/i/group_by.html)

---

## 学んだこと（まとめ）

- `group_by` で同じキーを持つレコードをまとめられる
- 複数レコードを1行に集約するときは `first`/`last` で最初・最後を取得する
- `form_with` のデフォルトはAjax。通常のHTTPリクエストにしたいときは `local: true` を付ける
- `local: true` の `do |f|` の `f` はフォームビルダーオブジェクト（道具箱）
- 処理が長くなるときはプライベートメソッドに切り出すと読みやすくなる

---

## 参照した公式ドキュメント

- [Ruby group_by](https://docs.ruby-lang.org/ja/latest/method/Enumerable/i/group_by.html) - 配列のグループ化
- [Action View フォームヘルパー](https://guides.rubyonrails.org/form_helpers.html) - form_with の使い方
- [Rails ルーティング - member](https://guides.rubyonrails.org/routing.html#adding-more-restful-actions) - memberルートの定義方法

---

## 次のステップへ

次は Phase8 ステップ1「権限チェックの実装（管理者・上長・一般ユーザーの相互アクセス禁止）」に進みます。
