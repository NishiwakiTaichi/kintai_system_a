class RemoveOvertimeFieldsFromAttendances < ActiveRecord::Migration[7.1]
  def change
    remove_column :attendances, :overtime_work, :string
    remove_column :attendances, :superior, :string
  end
end
