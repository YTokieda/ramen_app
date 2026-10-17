class AddActivationSentAtToUsers < ActiveRecord::Migration[7.2]
  def change
    add_column :users, :activation_sent_at, :datetime
  end
end
