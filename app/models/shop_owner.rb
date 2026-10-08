class ShopOwner < ApplicationRecord
  belongs_to :user
  belongs_to :shop
  has_one_attached :business_license # ActiveStorageを利用
  
  has_many :review_reply, dependent: :destroy

  validates :user_id,
            uniqueness: {
              scope: :shop_id,
              message: "はすでにこの店舗のオーナー申請をしています"
            }

  validates :status,
            inclusion: {
              in: %w[pending approved rejected]
            }

end
