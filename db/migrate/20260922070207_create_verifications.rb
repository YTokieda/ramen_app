class CreateVerifications < ActiveRecord::Migration[7.0]
  def change
    create_table :verifications do |t|
      t.references :shop, null: false, foreign_key: true
      t.references :menu_item, null: true, foreign_key: true
      t.string :category
      t.string :egg_status
      t.string :source_type
      t.string :verification_method
      t.date :verified_on
      t.text :note

      t.timestamps
    end
  end
end
