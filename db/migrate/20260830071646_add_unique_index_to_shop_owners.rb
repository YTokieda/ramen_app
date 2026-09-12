class AddUniqueIndexToShopOwners < ActiveRecord::Migration[7.0]
  def change
    add_index :shop_owners,
              [:user_id, :shop_id],
              unique: true
  end
end