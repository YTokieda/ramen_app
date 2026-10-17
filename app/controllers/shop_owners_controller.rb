class ShopOwnersController < ApplicationController
  before_action :logged_in_user
  before_action :authorized_shop_owner,
              only: [:edit_shop, :update_shop]
  

  def new
    @shop = find_shop(params[:shop_id])

    @shop_owner = current_user.shop_owners.build(
      shop: @shop
    )
  end

  def create
    @shop = find_shop(params[:shop_owner][:shop_id])
  
    @shop_owner = current_user.shop_owners.build(
      shop: @shop,
      **params.require(:shop_owner).permit(:applicant_name, :applicant_role, :shop_phone).to_h.symbolize_keys
    )
  
    upload = params[:shop_owner][:business_license].presence
    upload = nil unless upload.respond_to?(:tempfile)
  
    @shop_owner.business_license = upload
  
    invalid_upload =
      upload.present? &&
      !UploadContentTypeValidator.valid_upload?(
        upload,
        allowed_types: ShopOwner::LICENSE_CONTENT_TYPES
      )
  
    if invalid_upload
      @shop_owner.errors.add(
        :business_license,
        "のファイル形式が正しくありません"
      )
    end
  
    if !invalid_upload && @shop_owner.save(context: :application)
      flash[:success] = "店舗オーナー申請を送信しました"
      redirect_to @shop
    else
      render :new, status: :unprocessable_entity
    end
  end
  
  
  def dashboard
    @shop_owners = current_user.shop_owners
                    .where(status: "approved")
                    .includes(:shop)
  end
  
  def edit_shop
   @shop = @shop_owner.shop
  end

  def update_shop
    @shop = @shop_owner.shop
  
    if @shop.update(shop_params)
      flash[:success] = "店舗情報を更新しました"
      redirect_to dashboard_shop_owners_path
    else
      render :edit_shop, status: :unprocessable_entity
    end
  end
    
    
  private
  
  def authorized_shop_owner
    @shop_owner = current_user.shop_owners.find_by(
      id: params[:id],
      status: "approved"
    )
  
    unless @shop_owner
      flash[:danger] = "この店舗を編集する権限がありません"
      redirect_to dashboard_shop_owners_path
    end
  end
  
  def shop_params
    params.require(:shop).permit(
      :name,
      :address,
      :description,
      :website_url
    )
  end
  
end