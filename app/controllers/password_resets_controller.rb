class PasswordResetsController < ApplicationController
  # 再設定メールの大量送信を防ぐ
  rate_limit to: 5, within: 10.minutes, only: :create,
             with: -> { redirect_to new_password_reset_path, alert: I18n.t("auth.too_many_attempts"), status: :see_other }
  before_action :get_user,   only: [:edit, :update]
  before_action :valid_user, only: [:edit, :update]
  before_action :check_expiration, only: [:edit, :update]
  
  def new
  end
  
  def create
    email = params[:password_reset][:email].to_s.strip.downcase
    if email.blank?
      flash.now[:danger] = "メールアドレスを入力してください。"
      render 'new', status: :unprocessable_entity
      return
    end

    @user = User.find_by(email: email)
    if @user&.activated?
      @user.create_reset_digest
      @user.send_password_reset_email
    end
    # 登録の有無が分からないよう、結果にかかわらず同じ案内を出す
    flash[:info] = "登録済みのメールアドレスであれば、パスワード再設定用のメールを送信しました。"
    redirect_to root_url
  end

  def edit
  end
  
  def update
    if params[:user][:password].empty?                  # （3）への対応
      @user.errors.add(:password, :blank)
      render 'edit', status: :unprocessable_entity
    elsif @user.update(user_params)                     # （4）への対応
      # 再設定リンクを使い捨てにし、ほかの端末のログインも無効にする
      @user.update_columns(reset_digest: nil, reset_sent_at: nil)
      @user.forget
      reset_session
      log_in @user
      flash[:success] = "パスワードを変更しました。"
      redirect_to @user
    else
      render 'edit', status: :unprocessable_entity      # （2）への対応
    end
  end
  
    private
    
    def user_params
      params.require(:user).permit(:password, :password_confirmation)
    end

    def get_user
      @user = User.find_by(email: params[:email])
    end

    # 正しいユーザーかどうか確認する
    def valid_user
      unless (@user && @user.activated? &&
              @user.authenticated?(:reset, params[:id]))
        redirect_to root_url
      end
    end
    
    def check_expiration
      if @user.password_reset_expired?
        flash[:danger] = "再設定用リンクの有効期限が切れています。もう一度お手続きください。"
        redirect_to new_password_reset_url
      end
    end
  
end
