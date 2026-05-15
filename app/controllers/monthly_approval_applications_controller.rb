class MonthlyApprovalApplicationsController < ApplicationController
  before_action :authenticate_user!

  def create
    # Phase 6 で申請ロジックを実装
    redirect_to user_path(params[:monthly_approval_application][:user_id],
                          date: params[:monthly_approval_application][:target_month])
  end
end
