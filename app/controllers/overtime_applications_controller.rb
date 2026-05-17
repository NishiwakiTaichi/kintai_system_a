class OvertimeApplicationsController < ApplicationController
  before_action :authenticate_user!

  def create
    ot = overtime_application_params
    attendance = Attendance.find(ot[:attendance_id])

    # 翌日フラグに応じて基準日を決める
    next_day = ot[:next_day] == "1"
    base_date = next_day ? attendance.worked_on.tomorrow : attendance.worked_on

    # 時・分を組み合わせて datetime を作る
    scheduled_end_time = base_date.beginning_of_day +
                         ot[:scheduled_end_time_hour].to_i.hours +
                         ot[:scheduled_end_time_minute].to_i.minutes

    OvertimeApplication.create!(
      user_id:            ot[:user_id],
      attendance_id:      ot[:attendance_id],
      supervisor_id:      ot[:supervisor_id],
      scheduled_end_time: scheduled_end_time,
      next_day:           next_day,
      work_content:       ot[:work_content],
      status:             '申請中'
    )

    redirect_to user_path(ot[:user_id])
  end

  def bulk_update
    # 変更チェックボックスが入っている行のみステータスを更新する
    params[:overtime_applications]&.each do |id, attrs|
      next unless attrs[:change] == "1"

      OvertimeApplication.find(id).update(status: attrs[:status])
    end

    redirect_to user_path(current_user)
  end

  private

  def overtime_application_params
    params.require(:overtime_application).permit(
      :user_id, :attendance_id, :supervisor_id,
      :scheduled_end_time_hour, :scheduled_end_time_minute,
      :next_day, :work_content
    )
  end
end
