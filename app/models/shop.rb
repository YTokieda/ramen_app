class Shop < ApplicationRecord
    has_many :reviews, dependent: :destroy
    has_one :shop_owner, dependent: :destroy
    validates :name, presence: true
    validates :address, presence: true
    
    validates :name, uniqueness: { scope: :address, message: "この店舗はすでに登録されています" }
    
end
