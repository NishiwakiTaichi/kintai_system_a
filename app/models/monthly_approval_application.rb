class MonthlyApprovalApplication < ApplicationRecord
  belongs_to :user                            # 申請者
  belongs_to :supervisor, class_name: 'User'  # 申請先の上長
  # attendance には紐付かない（月単位の申請のため）
end
