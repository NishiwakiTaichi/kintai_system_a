class Users::RegistrationsController < Devise::RegistrationsController
  def update
    # パスワード欄が空なら current_password なしで更新
    if params[:user][:password].blank?
      @user = resource
      excluded = %i[current_password password password_confirmation]
      if @user.update_without_password(account_update_params.except(*excluded))
        bypass_sign_in(@user)
        redirect_to edit_user_registration_path, notice: "アカウント情報を更新しました"
      else
        render :edit
      end
    else
      super
    end
  end
end
