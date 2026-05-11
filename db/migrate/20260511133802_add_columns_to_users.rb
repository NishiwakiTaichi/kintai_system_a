class AddColumnsToUsers < ActiveRecord::Migration[7.1]
  def change
    add_column :users, :uid, :string
    add_column :users, :designated_work_start_time, :datetime
    add_column :users, :designated_work_end_time, :datetime
    add_column :users, :superior, :boolean, default: false
    rename_column :users, :employee_code, :employee_number
  end
end
