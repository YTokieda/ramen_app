class MenuItemsController < ApplicationController
  before_action :logged_in_user
  before_action :set_editable_menu_item, only: [:edit, :update]

  def new
    @shop = find_shop(params[:shop_id])
    @menu_item = @shop.menu_items.build
  end

  def create
    @shop = find_shop(params[:shop_id])
    @menu_item = @shop.menu_items.build(menu_item_params)

    if @menu_item.save
      flash[:success] = "メニューを登録しました。"
      redirect_to @shop
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
  end

  def update
    if @menu_item.update(menu_item_params)
      flash[:success] = "メニューを更新しました。"
      redirect_to @shop
    else
      render :edit, status: :unprocessable_entity
    end
  end

  private

  # メニューを編集できるのは、承認済みの店舗オーナーと運営だけ
  def set_editable_menu_item
    @shop = find_shop(params[:shop_id])
    @menu_item = @shop.menu_items.find(params[:id])
    return if current_user.can_manage_shop?(@shop)

    flash[:danger] = "このメニューを編集する権限がありません"
    redirect_to @shop
  end

  def menu_item_params
    params.require(:menu_item).permit(
      :name,
      :description
    )
  end
end