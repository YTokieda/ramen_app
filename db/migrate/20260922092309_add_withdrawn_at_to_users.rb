class AddWithdrawnAtToUsers < ActiveRecord::Migration[7.0]
  def change
    add_column :users, :withdrawn_at, :datetime
  end
end
