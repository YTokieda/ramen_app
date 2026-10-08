class ShopOwnersController < ApplicationController
  before_action :logged_in_user
  before_action :authorized_shop_owner,
              only: [:edit_shop, :update_shop]
  

  def new
    @shop = Shop.find(params[:shop_id])

    @shop_owner = current_user.shop_owners.build(
      shop: @shop
    )
  end

  def create
    @shop = Shop.find(params[:shop_owner][:shop_id])

    @shop_owner = current_user.shop_owners.build(
      shop: @shop
    )

    @shop_owner.business_license =
      params[:shop_owner][:business_license]

    if @shop_owner.save
      flash[:success] = "店舗オーナー申請を送信しました"
      redirect_to @shop
    else
      render :new, status: :unprocessable_entity
    end
  end
  
  
  def dashboard
    @shop_owners = current_user.shop_owners
                    .where(status: "approved")
                    .includes(:shop)
  end
  
  def edit_shop
   @shop = @shop_owner.shop
  end

  def update_shop
    @shop = @shop_owner.shop
  
    if @shop.update(shop_params)
      flash[:success] = "店舗情報を更新しました"
      redirect_to dashboard_shop_owners_path
    else
      render :edit_shop, status: :unprocessable_entity
    end
  end
    
    
  private
  
  def authorized_shop_owner
    @shop_owner = current_user.shop_owners.find_by(
      id: params[:id],
      status: "approved"
    )
  
    unless @shop_owner
      flash[:danger] = "この店舗を編集する権限がありません"
      redirect_to dashboard_shop_owners_path
    end
  end
  
  def shop_params
    params.require(:shop).permit(
      :name,
      :address,
      :description
    )
  end
  
end