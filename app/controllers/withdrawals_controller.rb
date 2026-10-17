class WithdrawalsController < ApplicationController
  rate_limit to: 5, within: 10.minutes, only: :create,
             with: -> { redirect_to new_withdrawal_path, alert: I18n.t("auth.too_many_attempts"), status: :see_other }
  before_action :logged_in_user

  def new
  end

  def create
    unless current_user.authenticate(params.dig(:withdrawal, :password).to_s)
      flash.now[:danger] = "パスワードが正しくありません。"
      render :new, status: :unprocessable_entity
      return
    end

    current_user.withdraw!
    # 退会後のユーザーはもうログイン中と見なされないので、セッションとクッキーを直接消す
    cookies.delete(:user_id)
    cookies.delete(:remember_token)
    reset_session
    @current_user = nil
    flash[:success] = "退会しました。ご利用ありがとうございました。"
    redirect_to root_url, status: :see_other
  end
end
