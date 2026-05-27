# ステップ2: CSV出力機能の実装

## このステップでやったこと（目次）

- **やったこと1**: `export_csv` アクションをコントローラーに追加した
- **やったこと2**: ルーティングに `get :export_csv` を追加した
- **やったこと3**: ビューのCSV出力ボタンのリンクを実際のパスに変更した

📝 詳細は以下の各セクションを参照

---

## 概要
勤怠ページの「CSV出力」ボタンを押すと、表示中の月の勤怠データ（出社・退社時間）をCSVファイルとしてダウンロードできる機能を実装した。

---

## 確認した仕様書

| ファイル | タブ名 | 確認内容 |
|---------|--------|---------|
| `docs/spec/test_cases.md` | 「テストケース一覧」 | 一般ユーザー No.10、上長ユーザー No.19 |
| `docs/spec/curriculum.md` | 「Phase7」 | ステップ2: CSV出力機能 |

**テストケース内容:**
- 一般ユーザー No.10: CSVを出力ボタン押下で表示月の勤怠情報（未承認の変更申請を除く）をCSV形式でダウンロード可能。最低限、表示月全ての出社と退社が表示されていればOK
- 上長ユーザー No.19: 同様

---

## 何をするのか（考え方）

CSVダウンロードとは、ブラウザに「このデータをファイルとして保存してください」と伝える処理です。

例え話：Webページを表示するときは「ここに画面を表示して」というリクエストです。CSVダウンロードは「このデータをファイルとして送って」というリクエストで、Railsの `send_data` メソッドがその役割を担います。

---

## 手順

### 1. ルーティングの追加（`config/routes.rb`）

#### 説明
`export_csv` アクションへのURLを定義する。

#### コード例
```ruby
member do
  get  :edit_basic_info
  patch :update_basic_info
  get  :export_csv   # 追加
end
```

#### コードの詳細解説

**`member do ... end` の中に書く意味**
- `member` の中に書くと「特定ユーザーへの操作」を意味する
- URL例: `/users/1/export_csv`
- `get :export_csv` により `export_csv_user_path(@user)` というURLヘルパーが自動生成される

📖 **公式ドキュメント**: [Rails ルーティング - member](https://guides.rubyonrails.org/routing.html#adding-more-restful-actions)

---

### 2. コントローラーの変更（`app/controllers/users_controller.rb`）

#### 説明
`require "csv"` を追加し、`before_action` に `export_csv` を加えて、アクション本体を実装する。

#### コード例
```ruby
require "csv"

class UsersController < ApplicationController
  before_action :set_user, only: %i[... export_csv]
  before_action :admin_or_correct_user, only: %i[... export_csv]
  before_action :set_one_month, only: %i[... export_csv]

  def export_csv
    csv_data = CSV.generate(headers: true, encoding: "UTF-8") do |csv|
      csv << ["日付", "出社時間", "退社時間"]
      @attendances.each do |attendance|
        csv << [
          attendance.worked_on.strftime("%m/%d"),
          attendance.started_at&.strftime("%H:%M"),
          attendance.finished_at&.strftime("%H:%M")
        ]
      end
    end

    filename = "#{@user.name}_#{@first_day.strftime('%Y%m')}_勤怠.csv"
    send_data "﻿#{csv_data}", filename: filename, type: "text/csv"
  end
end
```

#### コードの詳細解説

**1行目: `require "csv"`**
- Rubyの標準ライブラリ `csv` を読み込む
- Rails では自動読み込みされないため、明示的に書く必要がある

**`before_action` への追加**
- `:set_user` → `@user` を取得（誰のCSVか）
- `:admin_or_correct_user` → 本人か管理者だけアクセスできる（セキュリティ）
- `:set_one_month` → 表示月の `@attendances` を取得

**`CSV.generate(headers: true, encoding: "UTF-8") do |csv|`**
- CSVデータを文字列として生成するブロック
- `encoding: "UTF-8"` で文字コードを指定

**`csv << ["日付", "出社時間", "退社時間"]`**
- `<<` で行を追加する。配列の各要素がCSVの列になる
- これがヘッダー行

**`attendance.worked_on.strftime("%m/%d")`**
- 日付を「05/28」形式に変換する
- `strftime` はRubyの日付フォーマットメソッド

**`attendance.started_at&.strftime("%H:%M")`**
- `&.`（ぼっち演算子）: `started_at` が nil のとき nil を返す
- 出社していない日は started_at が nil になるため必要

**`send_data "﻿#{csv_data}", filename: filename, type: "text/csv"`**
- ブラウザにファイルとして送信する
- `﻿` はBOM（Byte Order Mark）。Excelで開いたときに文字化けを防ぐ
- `filename:` でダウンロード時のファイル名を指定

📖 **公式ドキュメント**: [Ruby CSV](https://docs.ruby-lang.org/ja/latest/class/CSV.html)
📖 **公式ドキュメント**: [Rails send_data](https://api.rubyonrails.org/classes/ActionController/DataStreaming.html#method-i-send_data)

#### なぜ `@attendances` をそのまま使えばいい？

仕様書には「未承認の変更申請を除く」とあるが、特別な処理が不要な理由：

- 勤怠変更申請が「申請中」のとき → `attendances` テーブルは変更されていない（元のデータのまま）
- 勤怠変更申請が「承認済み」になったとき → `attendances` テーブルが更新される

つまり `@attendances` には「承認済みの変更のみ反映されたデータ」が入っているため、そのまま使えばOK。

---

### 3. ビューの変更（`app/views/users/show.html.erb`）

#### コード例
```erb
<%= link_to "CSV出力", export_csv_user_path(@user, date: @first_day),
            class: "btn btn-app btn-sm" %>
```

#### コードの詳細解説

- 以前は `"#"` （ダミーリンク）だったものを、実際のパスに変更
- `export_csv_user_path(@user, date: @first_day)` → routes.rbで定義したパスへのURLヘルパー
- `date: @first_day` を渡すことで、現在表示している月のCSVをダウンロードできる

---

## 重要な概念

### BOM（Byte Order Mark）

**とは**:
ファイルの先頭に付ける特殊な文字列で、このファイルがどの文字コードで書かれているかを示す目印。

**なぜ必要か**:
ExcelでCSVを開くとき、BOMがないとUTF-8と認識できずに文字化けすることがある。`﻿` という文字列がBOM（UTF-8のBOM）。

### ぼっち演算子 `&.`

**とは**:
`object&.method` と書くと、`object` が nil のとき nil を返し、nil でないときは `method` を呼び出す。

**使い方**:
```ruby
# 普通の書き方（nil エラーが出る可能性あり）
attendance.started_at.strftime("%H:%M")  # started_at が nil だとエラー

# ぼっち演算子を使った書き方（安全）
attendance.started_at&.strftime("%H:%M")  # nil のとき nil を返す
```

📖 **公式ドキュメント**: [Ruby ぼっち演算子](https://docs.ruby-lang.org/ja/latest/doc/NEWS_for_ruby_2_3_0.html)

---

## 学んだこと（まとめ）

- `CSV.generate` でCSVデータを文字列として生成できる
- `send_data` でブラウザにファイルをダウンロードさせることができる
- UTF-8のBOM（`﻿`）をファイル先頭に付けるとExcelでの文字化けを防げる
- ぼっち演算子 `&.` でnilチェックをシンプルに書ける
- `member do ... end` の中にルートを書くと特定リソースへの操作URLが作れる

---

## 参照した公式ドキュメント

- [Ruby CSV](https://docs.ruby-lang.org/ja/latest/class/CSV.html) - CSVクラスの使い方
- [Rails send_data](https://api.rubyonrails.org/classes/ActionController/DataStreaming.html#method-i-send_data) - ファイル送信メソッド
- [Rails ルーティング - member](https://guides.rubyonrails.org/routing.html#adding-more-restful-actions) - memberルートの定義方法

---

## 次のステップへ

次は Phase7 ステップ3「勤怠修正ログページの実装」に進みます。
