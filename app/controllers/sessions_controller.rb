class SessionsController < ApplicationController
  # パスワードの総当たりを防ぐ
  rate_limit to: 10, within: 3.minutes, only: :create,
             with: -> { redirect_to login_path, alert: I18n.t("auth.too_many_attempts"), status: :see_other }

  def new
    
  end
  
  def create
    user = User.find_by(email: params[:session][:email].downcase)
    if user && user.authenticate(params[:session][:password])
      if user.activated?
        forwarding_url = session[:forwarding_url] 
        reset_session
        params[:session][:remember_me] == '1' ? remember(user) : forget(user)
        log_in user
        redirect_to forwarding_url || root_url
      else
        message  = "アカウントが有効になっていません。"
        message += "登録確認メールのリンクを開くか、ここから確認メールを再送してください。"
        flash[:warning] = message
        redirect_to new_account_activation_path
      end
    else
      flash.now[:danger] = 'メールアドレスまたはパスワードが正しくありません。'
      render 'new', status: :unprocessable_entity
    end
  end
  
  def destroy
    log_out if logged_in?
    redirect_to root_url, status: :see_other
  end
end
