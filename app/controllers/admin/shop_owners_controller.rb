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
  
    processed = false
  
    @shop_owner.with_lock do
      if @shop_owner.status == "pending"
        @shop_owner.update!(status: "approved")
        
        AdminAuditLog.create!(
          admin_user: current_user,
          target_type: "ShopOwner",
          target_id: @shop_owner.id,
          action_type: "approve",
          previous_status: "pending",
          new_status: "approved"
        )
          
        processed = true
      end
    end
  
    if processed
      notify_result(approved: true)
      flash[:success] = "店舗オーナー申請を承認しました"
    else
      flash[:danger] = "この申請はすでに処理されています"
    end
  
    redirect_to admin_shop_owners_path
  end

  def reject
    @shop_owner = ShopOwner.find(params[:id])
  
    processed = false
  
    @shop_owner.with_lock do
      if @shop_owner.status == "pending"
        @shop_owner.update!(status: "rejected")
        
        AdminAuditLog.create!(
          admin_user: current_user,
          target_type: "ShopOwner",
          target_id: @shop_owner.id,
          action_type: "reject",
          previous_status: "pending",
          new_status: "rejected"
        )
        
        processed = true
      end
    end
  
    if processed
      notify_result(approved: false)
      flash[:success] = "店舗オーナー申請を却下しました"
    else
      flash[:danger] = "この申請はすでに処理されています"
    end
  
    redirect_to admin_shop_owners_path
  end

  private

  def notify_result(approved:)
    ModerationMailer.notify(user: @shop_owner.user, kind: "shop_owner", approved: approved,
                            subject_name: @shop_owner.shop.name,
                            link_url: approved ? dashboard_shop_owners_url(locale: nil) : user_url(@shop_owner.user, locale: nil))
  end

end