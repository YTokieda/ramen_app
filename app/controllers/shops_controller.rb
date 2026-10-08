class ShopsController < ApplicationController
  def index
    @shops = Shop.all
  end
  
  def show
    @shop = Shop.find(params[:id])
    @reviews = @shop.reviews
    @review = Review.new
    @menu_items = @shop.menu_items
 
    approved_verifications =
      @shop.verifications
           .where(status: "approved")
           .includes(:menu_item, :user)
           .order(verified_on: :desc, created_at: :desc)
           
    @approved_verifications =
      approved_verifications
        .group_by { |verification|
        [verification.menu_item_id, verification.category]
        }
        .values
        .map(&:first)
        
    @verification_histories =
      approved_verifications
        .group_by { |verification|
          [verification.menu_item_id, verification.category]
        }
        .transform_values { |verifications|
          verifications.drop(1)
        }
             
    if logged_in?
      @my_unapproved_verifications =
        @shop.verifications
             .where(user: current_user)
             .where(status: ["pending", "rejected"])
             .includes(:menu_item)
    end
    
  end
  
end
