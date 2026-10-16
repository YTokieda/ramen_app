class ReviewReactionsController < ApplicationController
  before_action :logged_in_user
  before_action :set_review

  def create
    reaction = current_user.review_reactions.find_or_initialize_by(review: @review, kind: "helpful")
    flash[:danger] = reaction.errors.full_messages.first unless reaction.persisted? || reaction.save
    redirect_back_to_review
  rescue ActiveRecord::RecordNotUnique
    redirect_back_to_review
  end

  def destroy
    current_user.review_reactions.where(review: @review, kind: "helpful").destroy_all
    redirect_back_to_review
  end

  private

  def set_review
    @shop = Shop.find(params[:shop_id])
    @review = @shop.reviews.find(params[:review_id])
  end

  def redirect_back_to_review
    redirect_to shop_path(@shop, anchor: "review-#{@review.id}"), status: :see_other
  end
end
