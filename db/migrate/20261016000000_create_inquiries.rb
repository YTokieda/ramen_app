class CreateInquiries < ActiveRecord::Migration[7.2]
  def change
    create_table :inquiries do |t|
      t.references :user, foreign_key: true
      t.string :category, null: false
      t.string :name, null: false
      t.string :email, null: false
      t.text :body, null: false
      t.string :status, null: false, default: "new"
      t.timestamps
    end
    add_index :inquiries, :status
  end
end
