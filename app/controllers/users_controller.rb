class UsersController < ApplicationController
  before_action :authenticate_user!
  before_action :admin_user, only: [
    :index, :destroy, :edit_basic_info, :update_basic_info, :import, :user_attendance_index
  ]
  before_action :set_user, only: [
    :show, :edit, :update, :destroy, :edit_basic_info, :update_basic_info
  ]
  before_action :admin_or_correct_user, only: [:show, :edit, :update]
  before_action :set_one_month, only: [:show, :edit, :update]

  def user_attendance_index
    # 今日・出社済み・退社前 の勤怠レコードを持つユーザーを取得
    @attendances = Attendance.where(worked_on: Date.today)
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
    if current_user.superior?
      @overtime_requests       = OvertimeApplication
                                   .where(supervisor_id: current_user.id, status: '申請中')
                                   .includes(:user, :attendance)
      @overtime_count          = @overtime_requests.count
      @attendance_change_count = AttendanceChangeApplication.where(supervisor_id: current_user.id, status: '申請中').count
      @monthly_approval_count  = MonthlyApprovalApplication.where(supervisor_id: current_user.id, status: '申請中').count
    end

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

  def edit
  end

  def update
    failed_records = {}

    ActiveRecord::Base.transaction do
      params[:attendances]&.each do |id, attrs|
        attendance = @user.attendances.find(id)
        processed = parse_overnight_time(attendance_params(attrs), attendance.worked_on)
        attendance.assign_attributes(processed)
        failed_records[attendance.id] = attendance unless attendance.save(context: :edit_attendance)
      end
      raise ActiveRecord::Rollback if failed_records.any?
    end

    if failed_records.empty?
      redirect_to user_path(@user, date: @first_day), notice: "勤怠情報を更新しました。"
    else
      @attendances = @attendances.map { |a| failed_records[a.id] || a }
      render :edit, status: :unprocessable_entity
    end
  end

  def edit_basic_info
  end

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
      render :edit_basic_info, status: :unprocessable_entity
    end
  end

  def destroy
    @user.destroy
    redirect_to users_url, notice: "#{@user.name}を削除しました。"
  end

  private

  def attendance_params(attrs)
    attrs.permit(:started_at_hour, :started_at_minute, :finished_at_hour, :finished_at_minute, :note)
  end

  def parse_overnight_time(attrs, worked_on)
    result = { note: attrs[:note] }

    if attrs[:started_at_hour].present? && attrs[:started_at_minute].present?
      result[:started_at] = worked_on.beginning_of_day +
                            attrs[:started_at_hour].to_i.hours +
                            attrs[:started_at_minute].to_i.minutes
    else
      result[:started_at] = nil
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
