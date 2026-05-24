class AttendanceChangeApplicationsController < ApplicationController
  before_action :authenticate_user!

  def bulk_update
    params[:attendance_change_applications]&.each do |id, attrs|
      # 変更チェックが入っている申請のみ更新
      next unless attrs[:change] == "1"

      application = AttendanceChangeApplication.find(id)
      application.update(status: attrs[:status])
    end
    redirect_back_or_to root_path, notice: "勤怠変更申請を更新しました。"
  end
end
