class ReviewsController < ApplicationController
  before_action :logged_in_user

  def create
    @shop = Shop.find(params[:shop_id])
    @review = current_user.reviews.build(review_params)
    @review.shop = @shop

    if @review.save
      flash[:success] = "口コミを投稿しました"
      redirect_to @shop
    else
      @reviews = @shop.reviews
      render "shops/show", status: :unprocessable_entity
    end
  end
  
  
  def destroy
     @shop = Shop.find(params[:shop_id])
     @review = current_user.reviews.find_by(id: params[:id])
      if @review
        @review.destroy
        flash[:success] = "口コミを削除しました"
      else
        flash[:danger] = "この口コミは削除できません"
      end
    
    redirect_to @shop
  end

  private

  def review_params
    params.require(:review).permit(:content, images: [])
  end
end