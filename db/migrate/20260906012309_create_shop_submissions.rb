class CreateShopSubmissions < ActiveRecord::Migration[7.0]
  def change
    create_table :shop_submissions do |t|
      t.references :user, null: false, foreign_key: true
      t.string :name
      t.string :address
      t.text :description
      t.string :status

      t.timestamps
    end
  end
end
