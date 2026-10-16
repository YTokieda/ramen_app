class StaticPagesController < ApplicationController
  def home
    @shop_count = Shop.count
    @recent_verifications = Verification
      .where(status: "approved")
      .includes(:shop, :menu_item)
      .order(verified_on: :desc, id: :desc)
      .limit(5)
  end

  def help
  end
  
  def about
  end

  def privacy
  end

  def terms
  end
  
  
end
