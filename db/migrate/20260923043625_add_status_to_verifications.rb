class AddStatusToVerifications < ActiveRecord::Migration[7.0]
  def change
    add_column :verifications,
               :status,
               :string,
               null: false,
               default: "pending"

    add_index :verifications, :status
  end
end