class AttendanceChangeApplicationsController < ApplicationController
  before_action :authenticate_user!
  before_action :deny_admin

  def bulk_update
    params[:attendance_change_applications]&.each do |id, attrs|
      # 変更チェックが入っている申請のみ更新
      next unless attrs[:change] == "1"

      application = AttendanceChangeApplication.find(id)
      application.update(status: attrs[:status])

      # 承認された場合は勤怠データを実際の時刻で上書きする
      next unless attrs[:status] == "承認"

      application.attendance.update(
        started_at: application.after_started_at,
        finished_at: application.after_finished_at
      )
    end
    redirect_back_or_to root_path, notice: "勤怠変更申請を更新しました。"
  end
end
