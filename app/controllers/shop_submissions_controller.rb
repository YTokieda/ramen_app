class ShopSubmissionsController < ApplicationController
  before_action :logged_in_user

  def new
    @shop_submission = ShopSubmission.new
  end

  def create
    @shop_submission =
      current_user.shop_submissions.build(shop_submission_params)


    if @shop_submission.save
      flash[:success] = "店舗情報を送信しました"
      redirect_to shops_path
    else
      render :new, status: :unprocessable_entity
    end
  end

  private

  def shop_submission_params
    params.require(:shop_submission)
          .permit(:name, :address, :description)
  end
end