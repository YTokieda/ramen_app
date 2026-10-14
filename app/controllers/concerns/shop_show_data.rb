module ShopShowData
  extend ActiveSupport::Concern

  private

  def prepare_shop_show_data
    @reviews = @shop.reviews
    @menu_items = @shop.menu_items

    approved_verifications =
      @shop.verifications
           .where(status: "approved")
           .includes(:menu_item, :user)
           .order(verified_on: :desc, created_at: :desc)

    grouped_verifications =
      approved_verifications.group_by do |verification|
        [verification.menu_item_id, verification.category]
      end

    @approved_verifications =
      grouped_verifications.values.map(&:first)

    @verification_histories =
      grouped_verifications.transform_values do |verifications|
        verifications.drop(1)
      end

    if logged_in?
      @my_unapproved_verifications =
        @shop.verifications
             .where(user: current_user)
             .where(status: ["pending", "rejected"])
             .includes(:menu_item, evidence_files_attachments: :blob)

      @my_approved_verifications =
        @shop.verifications
             .where(user: current_user, status: "approved")
             .includes(:menu_item, evidence_files_attachments: :blob)
    end
  end
end