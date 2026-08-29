class ApplicationController < ActionController::Base
  include SessionsHelper
  helper_method :current_shop_owner, :shop_owner_logged_in?
  
  
  def current_shop_owner
    return @current_shop_owner if defined?(@current_shop_owner)
    if session[:shop_owner_id]
      @current_shop_owner = ShopOwner.find_by(id: session[:shop_owner_id])
    end
  end

  def shop_owner_logged_in?
    current_shop_owner.present?
  end

  def require_shop_owner
    unless shop_owner_logged_in?
      flash[:alert] = "店舗アカウントでログインしてください。"
      redirect_to shop_owner_login_path
    end
  end
  
    private

    def logged_in_user
      unless logged_in?
        store_location
        flash[:danger] = "Please log in."
        redirect_to login_url, status: :see_other
      end
    end
  
end