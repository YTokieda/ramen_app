class UsersController < ApplicationController
  # 登録確認メールの大量送信を防ぐ
  rate_limit to: 5, within: 10.minutes, only: :create,
             with: -> { redirect_to signup_path, alert: I18n.t("auth.too_many_attempts"), status: :see_other }
  before_action :logged_in_user, only: [:edit, :update, :destroy]
  before_action :correct_user,   only: [:edit, :update]
  before_action :admin_user,     only: [:index, :destroy]
  
  
  def show
    @user = User.find(params[:id])
  end
 
  def new
    @user = User.new
  end
  
  def create
    @user = User.new(user_params)
    unless params[:agree_terms] == "1"
      @user.valid?
      @user.errors.add(:base, "利用規約とプライバシーポリシーへの同意が必要です")
      render 'new', status: :unprocessable_entity
      return
    end
    if @user.save
      @user.send_activation_email
      flash[:info] = "確認メールを送信しました。メール内のリンクを開いて、登録を完了してください。"
      redirect_to root_url
    else
      
      render 'new', status: :unprocessable_entity
    end
  end
  
  def edit
    @user = User.find(params[:id])
  end
  
  def update
    @user = User.find(params[:id])
    if @user.update(user_params)
      flash[:success] = "アカウント情報を更新しました。"
      redirect_to @user
    else
      render 'edit', status: :unprocessable_entity
    end
  end
  
  def destroy
    User.find(params[:id]).destroy
    flash[:success] = "ユーザーを削除しました。"
    redirect_to users_url, status: :see_other
  end
  
  private
    def user_params
      params.require(:user).permit(:name, :email, :password, :password_confirmation)
    end
    
    def correct_user
      @user = User.find(params[:id])
      redirect_to(root_url, status: :see_other) unless current_user?(@user)
    end

  
end
