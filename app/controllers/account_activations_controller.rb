class AccountActivationsController < ApplicationController
  # 確認メールの大量送信を防ぐ
  rate_limit to: 5, within: 10.minutes, only: :create,
             with: -> { redirect_to new_account_activation_path, alert: I18n.t("auth.too_many_attempts"), status: :see_other }

  # 確認メールの再送フォーム
  def new
  end

  def create
    email = params.dig(:account_activation, :email).to_s.strip.downcase
    user = User.find_by(email: email)
    user.resend_activation_email if user && !user.activated?
    # 登録の有無が分からないよう、結果にかかわらず同じ案内を出す
    flash[:info] = "未有効のアカウントがある場合は、確認メールを送信しました。#{User::ACTIVATION_PERIOD.in_hours.to_i}時間以内にリンクを開いてください。"
    redirect_to root_url, status: :see_other
  end

  def edit
    user = User.find_by(email: params[:email])
    if user && !user.activated? && user.authenticated?(:activation, params[:id]) && user.activation_expired?
      flash[:danger] = "有効化リンクの期限が切れています。確認メールを再送してください。"
      redirect_to new_account_activation_path
    elsif user && !user.activated? && user.authenticated?(:activation, params[:id])
      user.activate
      log_in user
      flash[:success] = "アカウントが有効になりました。"
      redirect_to user
    else
      flash[:danger] = "有効化リンクが正しくありません。"
      redirect_to root_url
    end
  end
end
