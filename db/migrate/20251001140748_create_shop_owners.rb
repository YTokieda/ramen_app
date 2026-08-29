class CreateShopOwners < ActiveRecord::Migration[7.0]
  def change
    create_table :shop_owners do |t|
      t.string :name, null: false
      t.string :email, null: false
      t.string :password_digest
      t.references :shop, null: false, foreign_key: true

      t.timestamps
    end
    add_index :shop_owners, :email, unique: true
  end
end
