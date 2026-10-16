class CreateReviewReactions < ActiveRecord::Migration[7.2]
  def change
    create_table :review_reactions do |t|
      t.references :review, null: false, foreign_key: true
      t.references :user, null: false, foreign_key: true
      t.string :kind, null: false, default: "helpful"
      t.timestamps
    end
    add_index :review_reactions, [:review_id, :user_id, :kind], unique: true
  end
end
