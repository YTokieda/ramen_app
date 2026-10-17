class AddPrefectureToShops < ActiveRecord::Migration[7.2]
  class MigrationShop < ActiveRecord::Base
    self.table_name = "shops"
  end

  def up
    add_column :shops, :prefecture, :string
    add_index :shops, :prefecture

    MigrationShop.reset_column_information
    MigrationShop.find_each do |shop|
      shop.update_column(:prefecture, Prefecture.from_address(shop.address))
    end
  end

  def down
    remove_index :shops, :prefecture
    remove_column :shops, :prefecture
  end
end
