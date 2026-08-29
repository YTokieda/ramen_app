class ShopSessionsController < ApplicationController
  def new
  end
  
  def create
    owner = ShopOwner.find_by(email: params[:session][:email].downcase)
    if owner&.authenticate(params[:session][:password])
      session[:shop_owner_id] = owner.id
      redirect_to shop_owners_dashboard_path, notice: "ログインしました"
    else
      flash.now[:alert] = "メールまたはパスワードが正しくありません"
      render :new
    end
  end

  def destroy
    session.delete(:shop_owner_id)
    @current_shop_owner = nil
    redirect_to root_path, notice: "ログアウトしました"
  end
  
end
