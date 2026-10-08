class ReviewRepliesController < ApplicationController
  before_action :logged_in_user

  def create
    @shop = Shop.find(params[:shop_id])
    @review = @shop.reviews.find(params[:review_id])

    @shop_owner = current_user.shop_owners.find_by(
      shop: @shop,
      status: "approved"
    )

    unless @shop_owner
      flash[:danger] = "この口コミに返信する権限がありません"
      redirect_to @shop
      return
    end

    @review_reply = @review.build_review_reply(
      review_reply_params
    )

    @review_reply.shop_owner = @shop_owner

    if @review_reply.save
      flash[:success] = "口コミへ返信しました"
    else
      flash[:danger] = "返信を投稿できませんでした"
    end

    redirect_to @shop
  end

  private

  def review_reply_params
    params.require(:review_reply).permit(:content)
  end
end