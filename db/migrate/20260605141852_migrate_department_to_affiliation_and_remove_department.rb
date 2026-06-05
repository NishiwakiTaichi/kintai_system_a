class MigrateDepartmentToAffiliationAndRemoveDepartment < ActiveRecord::Migration[7.1]
  def up
    # departmentの値をaffiliationへコピー（affiliationが空の場合のみ）
    execute("UPDATE users SET affiliation = department WHERE affiliation IS NULL OR affiliation = ''")
    remove_column :users, :department
  end

  def down
    add_column :users, :department, :string
    execute("UPDATE users SET department = affiliation")
  end
end
