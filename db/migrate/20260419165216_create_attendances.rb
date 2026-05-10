class CreateAttendances < ActiveRecord::Migration[7.1]
  def change
    create_table :attendances do |t|
      t.date     :worked_on               # 日付
      t.datetime :started_at              # 出社時間
      t.datetime :finished_at             # 退社時間
      t.string   :note                    # 備考
      t.references :user, null: false, foreign_key: true  # 外部キー

      t.timestamps
    end
  end
end
