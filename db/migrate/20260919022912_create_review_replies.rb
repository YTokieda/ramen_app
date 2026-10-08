class CreateReviewReplies < ActiveRecord::Migration[7.0]
  def change
    create_table :review_replies do |t|
      t.references :review, null: false, foreign_key: true
      t.references :shop_owner, null: false, foreign_key: true
      t.text :content

      t.timestamps
    end
  end
end
