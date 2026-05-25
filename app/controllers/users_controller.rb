class UsersController < ApplicationController
  before_action :authenticate_user!
  before_action :admin_user, only: %i[
    index destroy edit_basic_info update_basic_info import user_attendance_index
  ]
  before_action :set_user, only: %i[
    show edit update destroy edit_basic_info update_basic_info
  ]
  before_action :admin_or_correct_user, only: %i[show edit update]
  before_action :set_one_month, only: %i[show edit update]
  before_action :set_attendance_change_form_options, only: %i[edit update]

  def user_attendance_index
    # 今日・出社済み・退社前 の勤怠レコードを持つユーザーを取得
    @attendances = Attendance.where(worked_on: Time.zone.today)
                             .where.not(started_at: nil)
                             .where(finished_at: nil)
                             .includes(:user)
  end

  def import
    User.import(params[:csv_file])
    redirect_to users_path, notice: "ユーザーをインポートしました。"
  end

  def index
    @users = if params[:name].present?
               User.where("name LIKE ?", "%#{params[:name]}%").paginate(page: params[:page], per_page: 20)
             else
               User.paginate(page: params[:page], per_page: 20)
             end
  end

  def show
    @worked_sum = @attendances.where.not(started_at: nil).count

    # 上長ユーザーの場合のみ、自分への申請データと件数を取得
    set_superior_notice_data if current_user.superior?

    # 所属長承認申請フォーム用：自身以外の上長ユーザーリスト
    @supervisors = User.where(superior: true).where.not(id: current_user.id)

    # 残業申請データを attendance_id をキーにしたハッシュで取得
    @overtime_applications = OvertimeApplication
                             .where(attendance_id: @attendances.map(&:id))
                             .index_by(&:attendance_id)

    # 勤怠変更申請データを attendance_id をキーにしたハッシュで取得
    @change_applications = AttendanceChangeApplication
                           .where(attendance_id: @attendances.map(&:id))
                           .index_by(&:attendance_id)

    # 現在表示中の月の所属長承認申請状態
    @monthly_approval = MonthlyApprovalApplication.find_by(
      user_id: @user.id,
      target_month: @first_day
    )
  end

  def edit; end

  def update
    @application_errors = []

    ActiveRecord::Base.transaction do
      params[:attendances]&.each do |id, attrs|
        attendance = @user.attendances.find(id)
        processed = parse_overnight_time(attendance_params(attrs), attendance.worked_on)
        process_attendance_row(attendance, attrs, processed)
      end
      raise ActiveRecord::Rollback if @application_errors.any?
    end

    if @application_errors.empty?
      redirect_to user_path(@user, date: @first_day), notice: "勤怠情報を更新しました。"
    else
      render :edit, status: :unprocessable_content
    end
  end

  def edit_basic_info; end

  def update_basic_info
    # パスワードが空欄なら変更しない
    result = if params[:user][:password].blank?
               @user.update_without_password(basic_info_params_without_password)
             else
               @user.update(basic_info_params)
             end

    if result
      redirect_to users_path, notice: "#{@user.name}の基本情報を更新しました。"
    else
      render :edit_basic_info, status: :unprocessable_content
    end
  end

  def destroy
    @user.destroy
    redirect_to users_url, notice: "#{@user.name}を削除しました。"
  end

  private

  def set_superior_notice_data
    @overtime_requests          = OvertimeApplication
                                  .where(supervisor_id: current_user.id, status: "申請中")
                                  .includes(:user, :attendance)
    @overtime_count             = @overtime_requests.count
    @attendance_change_requests = AttendanceChangeApplication
                                  .where(supervisor_id: current_user.id, status: "申請中")
                                  .includes(:user, :attendance)
    @attendance_change_count    = @attendance_change_requests.count
    @monthly_approval_requests  = MonthlyApprovalApplication
                                  .where(supervisor_id: current_user.id, status: "申請中")
                                  .includes(:user)
    @monthly_approval_count     = @monthly_approval_requests.count
  end

  def process_attendance_row(attendance, attrs, processed)
    supervisor_id = attrs[:supervisor_id].presence
    if supervisor_id
      save_change_application(attendance, processed, supervisor_id, attrs[:note])
    else
      attendance.assign_attributes(processed)
      @application_errors.concat(attendance.errors.full_messages) unless attendance.save(context: :edit_attendance)
    end
  end

  def save_change_application(attendance, processed, supervisor_id, reason)
    errors = validate_change_application(processed, attendance.worked_on)
    if errors.any?
      @application_errors.concat(errors)
      return
    end

    application = AttendanceChangeApplication.find_or_initialize_by(
      attendance_id: attendance.id,
      user_id: @user.id
    )
    application.assign_attributes(
      supervisor_id: supervisor_id,
      before_started_at: attendance.started_at,
      before_finished_at: attendance.finished_at,
      after_started_at: processed[:started_at],
      after_finished_at: processed[:finished_at],
      reason: reason,
      status: "申請中"
    )
    @application_errors << "勤怠変更申請の保存に失敗しました" unless application.save
  end

  def attendance_params(attrs)
    attrs.permit(:started_at_hour, :started_at_minute, :finished_at_hour, :finished_at_minute, :note, :supervisor_id)
  end

  def validate_change_application(processed, worked_on)
    messages = []
    started = processed[:started_at]
    finished = processed[:finished_at]

    # 出社のみ or 退社のみの入力はエラー
    if started.present? && finished.blank?
      messages << "#{worked_on.strftime('%m/%d')}: 退社時間も入力してください"
    elsif started.blank? && finished.present?
      messages << "#{worked_on.strftime('%m/%d')}: 出社時間も入力してください"
    end

    # 退社時間は出社時間より後でなければならない
    if started.present? && finished.present? && finished <= started
      messages << "#{worked_on.strftime('%m/%d')}: 退社時間は出社時間より後にしてください"
    end

    messages
  end

  def parse_overnight_time(attrs, worked_on)
    result = { note: attrs[:note] }

    result[:started_at] = if attrs[:started_at_hour].present? && attrs[:started_at_minute].present?
                            worked_on.beginning_of_day +
                              attrs[:started_at_hour].to_i.hours +
                              attrs[:started_at_minute].to_i.minutes
                          end

    if attrs[:finished_at_hour].present? && attrs[:finished_at_minute].present?
      hours = attrs[:finished_at_hour].to_i
      minutes = attrs[:finished_at_minute].to_i
      base_date = hours >= 24 ? worked_on.tomorrow : worked_on
      adjusted_hours = hours >= 24 ? hours - 24 : hours
      result[:finished_at] = base_date.beginning_of_day + adjusted_hours.hours + minutes.minutes
    else
      result[:finished_at] = nil
    end

    result
  end

  def set_attendance_change_form_options
    @supervisors = User.where(superior: true).where.not(id: current_user.id)
    @change_applications = AttendanceChangeApplication
                           .where(attendance_id: @attendances.map(&:id))
                           .index_by(&:attendance_id)
  end

  def basic_info_params
    params.require(:user).permit(
      :name, :email, :affiliation, :employee_number, :uid,
      :password, :password_confirmation,
      :basic_time, :designated_work_start_time, :designated_work_end_time
    )
  end

  def basic_info_params_without_password
    params.require(:user).permit(
      :name, :email, :affiliation, :employee_number, :uid,
      :basic_time, :designated_work_start_time, :designated_work_end_time
    )
  end
end
