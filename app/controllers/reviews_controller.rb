class ReviewsController < ApplicationController
  before_action :logged_in_user, only: [:create, :destroy]

  def create
    @shop = Shop.find(params[:shop_id])
    @review = @shop.reviews.build(review_params)
    @review.user = current_user
    if @review.save
      redirect_to @shop, notice: "口コミを投稿しました。"
    else
      redirect_to @shop, alert: "投稿に失敗しました。"
    end
  end

  def destroy
    @review = current_user.reviews.find(params[:id])
    @review.destroy
    redirect_to @review.shop, notice: "口コミを削除しました。"
  end

  private

  def review_params
    params.require(:review).permit(:content, :rating)
  end
end
