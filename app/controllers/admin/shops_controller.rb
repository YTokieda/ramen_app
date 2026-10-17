class Admin::ShopsController < ApplicationController
  before_action :logged_in_user
  before_action :admin_user

  def index
    @shops = Shop.order(Arel.sql("hidden_at IS NULL"), :name, :id)
  end

  def edit
    @shop = Shop.find(params[:id])
  end

  def update
    @shop = Shop.find(params[:id])
    @shop.assign_attributes(shop_params)
    changed = @shop.changed

    if changed.empty?
      redirect_to admin_shops_path, status: :see_other
    elsif Shop.transaction { @shop.save && log!(@shop, "update", changed.join(","), "updated") }
      flash[:success] = "「#{@shop.name}」の店舗情報を更新しました"
      redirect_to admin_shops_path, status: :see_other
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def hide
    shop = Shop.find(params[:id])
    unless shop.hidden?
      Shop.transaction do
        shop.update!(hidden_at: Time.current)
        log!(shop, "hide", "visible", "hidden")
      end
    end
    flash[:success] = "「#{shop.name}」を非公開にしました"
    redirect_to admin_shops_path, status: :see_other
  end

  def unhide
    shop = Shop.find(params[:id])
    if shop.hidden?
      Shop.transaction do
        shop.update!(hidden_at: nil)
        log!(shop, "unhide", "hidden", "visible")
      end
    end
    flash[:success] = "「#{shop.name}」を再公開しました"
    redirect_to admin_shops_path, status: :see_other
  end

  private

  def shop_params
    params.require(:shop).permit(:name, :address, :description, :website_url)
  end

  def log!(shop, action, from, to)
    AdminAuditLog.create!(admin_user: current_user, target_type: "Shop", target_id: shop.id,
                          action_type: action, previous_status: from, new_status: to)
  end
end
