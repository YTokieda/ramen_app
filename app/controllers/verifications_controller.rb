class VerificationsController < ApplicationController
  before_action :logged_in_user

  def new
    @shop = find_shop(params[:shop_id])

    @verification = current_user.verifications.build(
      shop: @shop
    )

    if params[:menu_item_id].present?
      @menu_item = @shop.menu_items.find(
        params[:menu_item_id]
      )

      @verification.menu_item = @menu_item
    end

    if params[:category] == "cooking_environment"
      @verification.category = "cooking_environment"
    end
  end
  
  def create
    @shop = find_shop(params[:shop_id])

    @verification =
      current_user.verifications.build(verification_params)

    @verification.shop = @shop

    if params[:menu_item_id].present?
      @menu_item = @shop.menu_items.find(
        params[:menu_item_id]
      )

      @verification.menu_item = @menu_item
    end

    # 未選択でもフォームから空文字が送られてくるので取り除く
    uploads = (verification_params[:evidence_files] || []).compact_blank

    invalid_upload = uploads.any? do |upload|
      !UploadContentTypeValidator.valid_upload?(
        upload,
        allowed_types: Verification::EVIDENCE_CONTENT_TYPES
      )
    end
    
    if invalid_upload
      @verification.errors.add(
        :evidence_files,
        "のファイル形式が正しくありません"
      )
      render :new, status: :unprocessable_entity
    elsif @verification.save
      redirect_to @shop
    else
      render :new, status: :unprocessable_entity
    end

  end
  
  private

  def verification_params
    params.require(:verification).permit(
      :category,
      :egg_status,
      :source_type,
      :verification_method,
      :verified_on,
      :note,
      evidence_files: []
    )
  end
  
end