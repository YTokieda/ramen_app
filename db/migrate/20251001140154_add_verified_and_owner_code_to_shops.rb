class AddVerifiedAndOwnerCodeToShops < ActiveRecord::Migration[7.0]
  def change
    add_column :shops, :verified, :boolean, default: false, null: false
    add_column :shops, :owner_code, :string
    add_index :shops, :owner_code, unique: true
  end
end
