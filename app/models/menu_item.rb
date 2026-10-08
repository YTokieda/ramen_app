class MenuItem < ApplicationRecord
  belongs_to :shop
  validates :name, presence: true,  uniqueness: {
              scope: :shop_id,
              message: "はすでに登録されています"
            }
  has_many :verifications, dependent: :destroy
  
end
