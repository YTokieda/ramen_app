class MenuItem < ApplicationRecord
  belongs_to :shop
  validates :name, presence: true,  uniqueness: {
              scope: :shop_id,
              message: "はすでに登録されています"
            }
  validates :name, length: { maximum: 100 }
  validates :description, length: { maximum: 1000 }
  has_many :verifications, dependent: :destroy
  
end
