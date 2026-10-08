class MenuItemsController < ApplicationController
  before_action :logged_in_user

  def new
    @shop = Shop.find(params[:shop_id])
    @menu_item = @shop.menu_items.build
  end

  def create
    @shop = Shop.find(params[:shop_id])
    @menu_item = @shop.menu_items.build(menu_item_params)

    if @menu_item.save
      flash[:success] = "メニューを登録しました。"
      redirect_to @shop
    else
      render :new, status: :unprocessable_entity
    end
  end

  private

  def menu_item_params
    params.require(:menu_item).permit(
      :name,
      :description
    )
  end
end