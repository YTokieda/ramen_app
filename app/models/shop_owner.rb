class ShopOwner < ApplicationRecord
  belongs_to :user
  belongs_to :shop
  has_one_attached :business_license # ActiveStorageを利用

  validates :user_id, uniqueness: { scope: :shop_id }

end
