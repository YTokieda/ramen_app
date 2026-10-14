module Admin
  class ShopOwnerLicensesController < ApplicationController
    before_action :logged_in_user
    before_action :admin_user

    def show
      shop_owner = ShopOwner.find(params[:shop_owner_id])

      unless shop_owner.business_license.attached?
        raise ActiveRecord::RecordNotFound
      end

      blob = shop_owner.business_license.blob

      response.headers["Cache-Control"] = "private, no-store"
      response.headers["X-Content-Type-Options"] = "nosniff"

      send_data blob.download,
                filename: blob.filename.to_s,
                type: "application/octet-stream",
                disposition: "attachment"
    end
  end
end