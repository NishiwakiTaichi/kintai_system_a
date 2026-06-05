class AddAffiliationToUsers < ActiveRecord::Migration[7.1]
  def change
    add_column :users, :affiliation, :string
  end
end
