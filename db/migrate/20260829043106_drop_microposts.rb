class DropMicroposts < ActiveRecord::Migration[7.0]
  def change
    drop_table :microposts
  end
end
