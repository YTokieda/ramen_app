class AddHiddenAtToShops < ActiveRecord::Migration[7.2]
  def change
    add_column :shops, :hidden_at, :datetime
  end
end
