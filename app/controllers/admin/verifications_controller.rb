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
    @verification.update!(status: "approved")

    flash[:success] = "卵情報を承認しました。"
    redirect_to admin_verifications_path
  end

  def reject
    @verification.update!(status: "rejected")

    flash[:success] = "卵情報を却下しました。"
    redirect_to admin_verifications_path
  end

  private

  def set_verification
    @verification = Verification.find(params[:id])
  end

end