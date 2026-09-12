class Admin::ShopSubmissionsController < ApplicationController
  before_action :logged_in_user
  before_action :admin_user

  def index
    @shop_submissions = ShopSubmission.all
  end

  def show
    @shop_submission = ShopSubmission.find(params[:id])
  end

  def approve
    @shop_submission = ShopSubmission.find(params[:id])

    unless @shop_submission.status == "pending"
      flash[:danger] = "この申請はすでに処理されています"
      redirect_to admin_shop_submissions_path
      return
    end

    existing_shop = Shop.find_by(
      name: @shop_submission.name,
      address: @shop_submission.address
      )
    
    if existing_shop
      flash[:danger] = "同じ店舗がすでに登録されています"
      redirect_to admin_shop_submission_path(@shop_submission)
      return
    end

    shop = Shop.new(
      name: @shop_submission.name,
      address: @shop_submission.address,
      description: @shop_submission.description
    )

    if shop.save
      @shop_submission.update(status: "approved")

      flash[:success] = "店舗情報を承認し、店舗を登録しました"
      redirect_to admin_shop_submissions_path
    else
      flash[:danger] = "店舗を登録できませんでした"
      redirect_to admin_shop_submission_path(@shop_submission)
    end
  end

  def reject
    @shop_submission = ShopSubmission.find(params[:id])
    @shop_submission.update(status: "rejected")

    flash[:success] = "店舗情報を却下しました"
    redirect_to admin_shop_submissions_path
  end

  private

  def admin_user
    redirect_to(root_url) unless current_user&.admin?
  end
end