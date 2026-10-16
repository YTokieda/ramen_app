class Admin::InquiriesController < ApplicationController
  before_action :logged_in_user
  before_action :admin_user

  def index
    @status = params[:status].presence_in(Inquiry::STATUSES.keys)
    @inquiries = Inquiry.order(created_at: :desc)
    @inquiries = @inquiries.where(status: @status) if @status
  end

  def show
    @inquiry = Inquiry.find(params[:id])
  end

  def update
    @inquiry = Inquiry.find(params[:id])
    previous_status = @inquiry.status

    if @inquiry.update(status: params.dig(:inquiry, :status))
      AdminAuditLog.create!(
        admin_user: current_user,
        target_type: "Inquiry",
        target_id: @inquiry.id,
        action_type: "update_status",
        previous_status: previous_status,
        new_status: @inquiry.status
      )
      redirect_to admin_inquiry_path(@inquiry), notice: "ステータスを更新しました。"
    else
      redirect_to admin_inquiry_path(@inquiry), alert: "ステータスを更新できませんでした。"
    end
  end
end
