class AddStatusToShopOwners < ActiveRecord::Migration[7.0]
  def change
    add_column :shop_owners,
               :status,
               :string,
               default: "pending",
               null: false
  end
end