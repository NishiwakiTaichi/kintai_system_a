class ApplicationController < ActionController::Base
  before_action :configure_permitted_parameters, if: :devise_controller?

  private

  # paramsのidからユーザーを取得する
  def set_user
    @user = User.find(params[:id])
  end

  # 管理者のみアクセスを許可する
  def admin_user
    redirect_to root_url unless current_user.admin?
  end

  # 管理者のアクセスを禁止する（勤怠・申請系ページ用）
  def deny_admin
    return unless current_user.admin?

    flash[:danger] = "このページにはアクセスできません。"
    redirect_to root_url
  end

  # 本人または上長のみアクセスを許可する（管理者は不可）
  def admin_or_correct_user
    @user = User.find(params[:user_id]) if @user.blank?
    return if current_user == @user || current_user.superior?

    flash[:danger] = "編集権限がありません。"
    redirect_to root_url
  end

  # 表示対象月の1ヶ月分の勤怠データを準備する
  def set_one_month
    @first_day = if params[:date].nil?
                   Date.current.beginning_of_month
                 else
                   params[:date].to_date
                 end
    @last_day = @first_day.end_of_month
    one_month = [*@first_day..@last_day]

    @attendances = @user.attendances.where(worked_on: @first_day..@last_day).order(:worked_on)

    # DBに存在しない日のレコードをまとめて作成する
    unless one_month.count == @attendances.count
      ActiveRecord::Base.transaction do
        one_month.each { |day| @user.attendances.find_or_create_by!(worked_on: day) }
      end
      @attendances = @user.attendances.where(worked_on: @first_day..@last_day).order(:worked_on)
    end
  rescue ActiveRecord::RecordInvalid
    flash[:danger] = "ページ情報の取得に失敗しました、再アクセスしてください。"
    redirect_to root_url
  end

  def configure_permitted_parameters
    devise_parameter_sanitizer.permit(:sign_up, keys: %i[name department])
    devise_parameter_sanitizer.permit(:account_update, keys: %i[name department])
  end
end
