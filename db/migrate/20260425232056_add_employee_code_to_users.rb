class AddEmployeeCodeToUsers < ActiveRecord::Migration[7.1]
  def change
    add_column :users, :employee_code, :string
  end
end
