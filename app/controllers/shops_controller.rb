class ShopsController < ApplicationController
  include ShopShowData
  def index
    @keyword = params[:keyword].to_s.strip
    @egg_status = params[:egg_status].to_s
    @category = params[:category].to_s
  
    allowed_egg_statuses = %w[egg_free contains_egg unknown]
    allowed_categories = %w[noodle_soup topping cooking_environment]
  
    @egg_status = "" unless allowed_egg_statuses.include?(@egg_status)
    @category = "" unless allowed_categories.include?(@category)
  
    @shops = Shop.search(
      keyword: @keyword,
      egg_status: @egg_status,
      category: @category
    )
    
    @verification_summaries = Shop.latest_verification_groups
      .select do |group|
        verification = group[:verification]
    
        @shops.any? { |shop| shop.id == verification.shop_id } &&
          (@category.blank? || verification.category == @category) &&
          (@egg_status.blank? ||
            (!group[:conflicting] &&
             verification.egg_status == @egg_status))
      end
      .group_by { |group| group[:verification].shop_id }
      
     @verification_summaries.each do |shop_id, summaries|
      @verification_summaries[shop_id] =
        summaries.sort_by do |summary|
          verification = summary[:verification]
    
          [
            summary[:conflicting] ? 0 : 1,
            -(verification.verified_on || Date.new(1900, 1, 1)).jd,
            -verification.id
          ]
        end
    end
    
  end
  
  def show
    @shop = Shop.find(params[:id])
    @review = Review.new
  
    prepare_shop_show_data
  end
  
end
