class CreateAttendanceChangeApplications < ActiveRecord::Migration[7.1]
  def change
    create_table :attendance_change_applications do |t|
      t.references :user,       null: false, foreign_key: true                    # 申請者
      t.references :supervisor, null: false, foreign_key: { to_table: :users }    # 上長
      t.references :attendance, null: false, foreign_key: true                    # 対象勤怠
      t.datetime   :before_started_at                                              # 変更前の出勤時間
      t.datetime   :before_finished_at                                             # 変更前の退勤時間
      t.text       :reason                                                         # 変更理由
      t.string     :status, default: 'なし'                                       # 申請状態

      t.timestamps
    end
  end
end
