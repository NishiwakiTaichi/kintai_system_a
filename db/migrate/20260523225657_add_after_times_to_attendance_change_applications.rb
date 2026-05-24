class AddAfterTimesToAttendanceChangeApplications < ActiveRecord::Migration[7.1]
  def change
    add_column :attendance_change_applications, :after_started_at, :datetime
    add_column :attendance_change_applications, :after_finished_at, :datetime
  end
end
