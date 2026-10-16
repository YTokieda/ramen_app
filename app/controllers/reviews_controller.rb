class ReviewsController < ApplicationController
  include ShopShowData
  before_action :logged_in_user

  def create
    @shop = Shop.find(params[:shop_id])
  
    uploads = review_params[:images] || []
  
    invalid_upload = uploads.any? do |upload|
      !UploadContentTypeValidator.valid_upload?(
        upload,
        allowed_types: %w[image/jpeg image/png image/webp]
      )
    end

    # 写真は公開されるので、撮影場所などの情報を消してから保存する
    uploads.each { |upload| ImageMetadataStripper.strip_upload!(upload) } unless invalid_upload

    @review = current_user.reviews.build(review_params)
    @review.shop = @shop
  
    if invalid_upload
      @review.errors.add(
        :images,
        "のファイル形式が正しくありません"
      )
    end
  

    if !invalid_upload && @review.save
      flash[:success] = "口コミを投稿しました"
      redirect_to @shop
    else
      prepare_shop_show_data
    
      render "shops/show", status: :unprocessable_entity
    end
    
  end
  
  
  def destroy
     @shop = Shop.find(params[:shop_id])
     @review = current_user.reviews.find_by(
        id: params[:id],
        shop_id: @shop.id
      )
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