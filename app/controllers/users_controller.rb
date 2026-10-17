class UsersController < ApplicationController
  # 登録確認メールの大量送信を防ぐ
  rate_limit to: 5, within: 10.minutes, only: :create,
             with: -> { redirect_to signup_path, alert: I18n.t("auth.too_many_attempts"), status: :see_other }
  before_action :logged_in_user, only: [:edit, :update, :destroy]
  before_action :correct_user,   only: [:edit, :update]
  before_action :admin_user,     only: [:index, :destroy]
  
  
  def show
    @user = User.find(params[:id])
    redirect_to(root_url, status: :see_other) and return unless @user.activated?

    @reviews = @user.reviews.where(shop: Shop.visible).includes(:shop).order(created_at: :desc)
                    .paginate(page: params[:page], per_page: 10)
    return unless current_user?(@user)

    # 本人にだけ見せる投稿の進み具合
    @shop_submissions = @user.shop_submissions.order(created_at: :desc)
    @verifications = @user.verifications.includes(:shop, :menu_item)
                          .order(created_at: :desc)
    @shop_owners = @user.shop_owners.includes(:shop).order(created_at: :desc)
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
      flash[:info] = "確認メールを送信しました。24時間以内にメール内のリンクを開いて、登録を完了してください。"
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
    avatar = params.dig(:user, :avatar).presence
    avatar = nil unless avatar.respond_to?(:tempfile)
    remove_avatar = params.dig(:user, :remove_avatar) == "1"

    @user.assign_attributes(user_params)

    # メールアドレスやパスワードを変えるときは、乗っ取り対策として今のパスワードを確かめる
    if (@user.will_save_change_to_email? || user_params[:password].present?) &&
       !User.find(@user.id).authenticate(params.dig(:user, :current_password).to_s)
      @user.errors.add(:base, "メールアドレスやパスワードを変更するには、今のパスワードを正しく入力してください")
      render 'edit', status: :unprocessable_entity and return
    end

    if avatar && (avatar.size > User::AVATAR_MAX_SIZE ||
                  !UploadContentTypeValidator.valid_upload?(avatar, allowed_types: User::AVATAR_TYPES))
      @user.errors.add(:avatar, "はJPEG・PNG・WebP形式で5MB以下の画像を選んでください")
      render 'edit', status: :unprocessable_entity and return
    end

    if avatar
      # 写真は公開されるので、撮影場所などの情報を消してから保存する
      ImageMetadataStripper.strip_upload!(avatar)
      @user.avatar = avatar
    end

    if @user.save
      @user.avatar.purge_later if remove_avatar && avatar.nil? && @user.avatar.attached?
      flash[:success] = "アカウント情報を更新しました。"
      redirect_to @user
    else
      render 'edit', status: :unprocessable_entity
    end
  end
  
  def destroy
    # 卵情報などの記録を残すため、削除ではなく退会と同じ扱いにする
    User.find(params[:id]).withdraw!
    flash[:success] = "ユーザーを退会扱いにしました。"
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
