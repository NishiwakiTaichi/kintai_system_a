class HomeController < ApplicationController
  def index
    # ログイン済みの場合は自分の勤怠ページへ
    redirect_to user_path(current_user) if user_signed_in?
  end
end
