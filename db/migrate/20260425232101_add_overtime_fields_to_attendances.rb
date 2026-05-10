class AddOvertimeFieldsToAttendances < ActiveRecord::Migration[7.1]
  def change
    add_column :attendances, :overtime_work, :string
    add_column :attendances, :superior, :string
  end
end
