class CreateMonthlyApprovalApplications < ActiveRecord::Migration[7.1]
  def change
    create_table :monthly_approval_applications do |t|
      t.references :user,       null: false, foreign_key: true                    # 申請者
      t.references :supervisor, null: false, foreign_key: { to_table: :users }    # 上長
      t.date       :target_month                                                   # 対象月（例: 2026-05-01）
      t.string     :status, default: 'なし'                                       # 申請状態

      t.timestamps
    end
  end
end
