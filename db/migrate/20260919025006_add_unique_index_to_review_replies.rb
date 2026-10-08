class AddUniqueIndexToReviewReplies < ActiveRecord::Migration[7.0]
  def change
    remove_index :review_replies, :review_id

    add_index :review_replies,
              :review_id,
              unique: true
  end
end