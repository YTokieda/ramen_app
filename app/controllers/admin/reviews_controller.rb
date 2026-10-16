class Admin::ReviewsController < ApplicationController
  before_action :logged_in_user
  before_action :admin_user

  def index
    @reviews = Review.includes(:user, :shop).order(created_at: :desc)
                     .paginate(page: params[:page], per_page: 30)
  end

  def destroy
    review = Review.find(params[:id])
    Review.transaction do
      review.destroy!
      AdminAuditLog.create!(admin_user: current_user, target_type: "Review", target_id: review.id,
                            action_type: "delete", previous_status: "published", new_status: "deleted")
    end
    flash[:success] = "口コミを削除しました"
    redirect_back_or_to admin_reviews_path, status: :see_other
  end
end
