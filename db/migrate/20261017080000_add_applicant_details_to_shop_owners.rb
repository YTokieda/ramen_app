class AddApplicantDetailsToShopOwners < ActiveRecord::Migration[7.2]
  def change
    add_column :shop_owners, :applicant_name, :string
    add_column :shop_owners, :applicant_role, :string
    add_column :shop_owners, :shop_phone, :string
    add_column :shop_owners, :reviewed_at, :datetime
  end
end
