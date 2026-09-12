class SetDefaultStatusForShopSubmissions < ActiveRecord::Migration[7.0]
  def change
    change_column_default :shop_submissions,
                          :status,
                          from: nil,
                          to: "pending"
  end
end