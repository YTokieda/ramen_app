class CreateShops < ActiveRecord::Migration[7.0]
  def change
    create_table :shops do |t|
      t.string :name, null: false
      t.string :address, null: false
      t.text :description
      t.boolean :egg_free, default: false

      t.timestamps
    end
    add_index :shops, [:name, :address], unique: true
  end
end
