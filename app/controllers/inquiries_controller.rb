class InquiriesController < ApplicationController
  # 短時間の大量送信を防ぐ
  rate_limit to: 5, within: 10.minutes, only: :create,
             with: -> { redirect_to new_inquiry_path, alert: I18n.t("inquiries.too_many") }

  def new
    @inquiry = Inquiry.new(category: params[:category])
    if logged_in?
      @inquiry.name = current_user.name
      @inquiry.email = current_user.email
    end
  end

  def create
    # ボット対策：人には見えない入力欄に値が入っていたら保存しない
    if params[:website].present?
      redirect_to root_path, notice: t("inquiries.thanks")
      return
    end

    @inquiry = Inquiry.new(inquiry_params)
    @inquiry.user = current_user if logged_in?

    if @inquiry.save
      notify_admin(@inquiry)
      redirect_to root_path, notice: t("inquiries.thanks")
    else
      render :new, status: :unprocessable_entity
    end
  end

  private

  def inquiry_params
    params.require(:inquiry).permit(:category, :name, :email, :body)
  end

  # 通知メールが失敗しても問い合わせ自体は保存済みなので、利用者にはエラーを見せない
  def notify_admin(inquiry)
    AdminMailer.new_inquiry(inquiry).deliver_now
  rescue StandardError => e
    Rails.logger.error("[Inquiry] admin notification failed: #{e.class}: #{e.message}")
  end
end
