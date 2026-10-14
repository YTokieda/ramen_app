class Admin::VerificationsController < ApplicationController
  before_action :logged_in_user
  before_action :admin_user
  before_action :set_verification, only: [:show, :approve, :reject]

  def index
    @verifications =
      Verification
        .where(status: "pending")
        .includes(:shop, :menu_item, :user)
        .order(created_at: :asc)
  end

  def show
  end
  
  def approve
    processed = false
  
    @verification.with_lock do
      if @verification.status == "pending"
        @verification.update!(status: "approved")
        
        AdminAuditLog.create!(
          admin_user: current_user,
          target_type: "Verification",
          target_id: @verification.id,
          action_type: "approve",
          previous_status: "pending",
          new_status: "approved"
        )
        
        processed = true
      end
    end
  
    if processed
      flash[:success] = "卵情報を承認しました。"
    else
      flash[:danger] = "この卵情報はすでに処理されています"
    end
  
    redirect_to admin_verifications_path
  end
  
  def reject
    processed = false
  
    @verification.with_lock do
      if @verification.status == "pending"
        @verification.update!(status: "rejected")
        
        AdminAuditLog.create!(
          admin_user: current_user,
          target_type: "Verification",
          target_id: @verification.id,
          action_type: "reject",
          previous_status: "pending",
          new_status: "rejected"
        )
          
        processed = true
      end
    end
  
    if processed
      flash[:success] = "卵情報を却下しました。"
    else
      flash[:danger] = "この卵情報はすでに処理されています"
    end
  
    redirect_to admin_verifications_path
  end
  
  private

  def set_verification
    @verification = Verification.find(params[:id])
  end

end