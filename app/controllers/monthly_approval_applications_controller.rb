class MonthlyApprovalApplicationsController < ApplicationController
  before_action :authenticate_user!

  def create
    supervisor_id = params[:monthly_approval_application][:supervisor_id].presence
    user_id       = params[:monthly_approval_application][:user_id]
    target_month  = params[:monthly_approval_application][:target_month]

    # 上長が未選択の場合はエラー
    if supervisor_id.blank?
      redirect_to user_path(user_id, date: target_month), alert: "申請先の上長を選択してください。"
      return
    end

    # 同じ月の申請が既にあれば上書き、なければ新規作成
    application = MonthlyApprovalApplication.find_or_initialize_by(
      user_id: user_id,
      target_month: target_month
    )
    application.assign_attributes(supervisor_id: supervisor_id, status: "申請中")
    application.save

    redirect_to user_path(user_id, date: target_month), notice: "所属長承認申請を送信しました。"
  end

  def bulk_update
    params[:monthly_approval_applications]&.each do |id, attrs|
      # 変更チェックが入っている申請のみ更新
      next unless attrs[:change] == "1"

      application = MonthlyApprovalApplication.find(id)
      application.update(status: attrs[:status])
    end
    redirect_back_or_to root_path, notice: "所属長承認申請を更新しました。"
  end
end
