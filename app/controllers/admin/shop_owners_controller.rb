class Admin::ShopOwnersController < ApplicationController
  before_action :logged_in_user
  before_action :admin_user

  def index
    @shop_owners = ShopOwner.all
  end

  def show
    @shop_owner = ShopOwner.find(params[:id])
  end

  def approve
    @shop_owner = ShopOwner.find(params[:id])

    unless @shop_owner.status == "pending"
      flash[:danger] = "この申請はすでに処理されています"
      redirect_to admin_shop_owners_path
      return
    end

    @shop_owner.update(status: "approved")

    flash[:success] = "店舗オーナー申請を承認しました"
    redirect_to admin_shop_owners_path
  end

  def reject
    @shop_owner = ShopOwner.find(params[:id])

    unless @shop_owner.status == "pending"
      flash[:danger] = "この申請はすでに処理されています"
      redirect_to admin_shop_owners_path
      return
    end

    @shop_owner.update(status: "rejected")

    flash[:success] = "店舗オーナー申請を却下しました"
    redirect_to admin_shop_owners_path
  end

  private

  def admin_user
    redirect_to(root_url) unless current_user&.admin?
  end
end