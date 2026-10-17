class AddWebsiteUrlToShops < ActiveRecord::Migration[7.2]
  def change
    add_column :shops, :website_url, :string
    add_column :shop_submissions, :website_url, :string
  end
end
