class StaticPagesController < ApplicationController
  def home
    @shop_count = Shop.visible.count
    @recent_verifications = Verification
      .where(status: "approved", shop: Shop.visible)
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
