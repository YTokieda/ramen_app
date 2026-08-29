class ShopOwnersController < ApplicationController
  # before_action :require_shop_owner, only: [:dashboard]

  def new
    @shop_owner = ShopOwner.new
    @shop_owner.build_shop # フォーム用に空のShopを作成
  end
  
  def create
    @shop_owner = ShopOwner.new(shop_owner_params)

    if @shop_owner.save
      flash[:success] = "店舗オーナー登録完了。店舗に紐づけられました。"
      redirect_to  dashboard_shop_owners_path
    else
      flash.now[:alert] = @shop_owner.errors.full_messages.join(", ")
      render :new
    end
  end
  
  def dashboard
    @shop = Shop.first
  end
  
  private

  def shop_owner_params
    params.require(:shop_owner).permit(
      :name, :email, :password, :password_confirmation, :business_license,
      shop_attributes: [:name, :address, :description]
    )
  end
end
