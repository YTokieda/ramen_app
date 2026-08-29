class ShopsController < ApplicationController
  before_action :require_shop_owner, only: [:verify]
  
  def index
    if params[:address].present?
      @shops = Shop.where("address LIKE ?", "%#{params[:address]}%")
    else
      @shops = Shop.all
    end
  end

  def show
    @shop = Shop.find(params[:id])
  end

  def new
    @shop = Shop.new
  end

  def create
    @shop = Shop.new(shop_params)
    if @shop.save
      redirect_to @shop, notice: "店舗を登録しました。"
    else
      render :new
    end
  end

  def verify
    @shop = Shop.find(params[:id])
    # 所有者が自分の店かチェック
    if current_shop_owner.shop_id == @shop.id
      @shop.update(verified: true)
      redirect_to @shop, notice: "店舗を確認済みにしました。"
    else
      redirect_to root_path, alert: "この操作は許可されていません。"
    end
  end

  private

  def shop_params
    params.require(:shop).permit(:name, :address, :description, :egg_free)
  end
end
