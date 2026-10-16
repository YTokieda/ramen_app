class Admin::MenuItemsController < ApplicationController
  before_action :logged_in_user
  before_action :admin_user

  def destroy
    menu_item = MenuItem.find(params[:id])
    shop = menu_item.shop
    MenuItem.transaction do
      menu_item.destroy!
      AdminAuditLog.create!(admin_user: current_user, target_type: "MenuItem", target_id: menu_item.id,
                            action_type: "delete", previous_status: "published", new_status: "deleted")
    end
    flash[:success] = "メニュー「#{menu_item.name}」を削除しました"
    redirect_to shop_path(shop), status: :see_other
  end
end
