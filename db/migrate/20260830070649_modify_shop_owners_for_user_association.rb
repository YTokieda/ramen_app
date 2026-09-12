class ModifyShopOwnersForUserAssociation < ActiveRecord::Migration[7.0]
  def change
    remove_column :shop_owners, :name, :string
    remove_column :shop_owners, :email, :string
    remove_column :shop_owners, :password_digest, :string

    add_reference :shop_owners, :user,
                  null: false,
                  foreign_key: true
  end
end