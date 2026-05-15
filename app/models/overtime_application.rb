class OvertimeApplication < ApplicationRecord
  belongs_to :user                            # 申請者
  belongs_to :supervisor, class_name: 'User'  # 申請先の上長
  belongs_to :attendance                      # 対象の勤怠レコード
end
