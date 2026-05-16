class OvertimeApplicationsController < ApplicationController
  before_action :authenticate_user!

  def create
    # Phase4 ステップ2で実装
    redirect_to user_path(params[:overtime_application][:user_id])
  end
end
