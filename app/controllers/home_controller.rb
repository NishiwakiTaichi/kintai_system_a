class HomeController < ApplicationController
  def index
    return unless user_signed_in?

    # 管理者はユーザー一覧ページへ、それ以外は自分の勤怠ページへ
    if current_user.admin?
      redirect_to users_path
    else
      redirect_to user_path(current_user)
    end
  end
end
