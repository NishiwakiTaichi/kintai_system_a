class CreateOvertimeApplications < ActiveRecord::Migration[7.1]
  def change
    create_table :overtime_applications do |t|
      t.references :user,       null: false, foreign_key: true                    # 申請者
      t.references :supervisor, null: false, foreign_key: { to_table: :users }    # 上長
      t.references :attendance, null: false, foreign_key: true                    # 対象勤怠
      t.datetime   :scheduled_end_time                                             # 終了予定時間
      t.boolean    :next_day,   default: false                                     # 翌日フラグ
      t.text       :work_content                                                   # 業務内容
      t.string     :status,     default: 'なし'                                   # 申請状態

      t.timestamps
    end
  end
end
