class ShopsController < ApplicationController
  def index
    @shops = Shop.all
  end
  
  def show
    @shop = Shop.find(params[:id])
    @reviews = @shop.reviews
    @review = Review.new
  end
  
end
