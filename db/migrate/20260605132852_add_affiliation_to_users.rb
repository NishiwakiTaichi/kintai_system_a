class AddAffiliationToUsers < ActiveRecord::Migration[7.1]
  def change
    # ローカル開発環境では既にカラムが存在するためスキップ
    add_column :users, :affiliation, :string unless column_exists?(:users, :affiliation)
  end
end
