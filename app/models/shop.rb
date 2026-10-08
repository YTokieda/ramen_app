class Shop < ApplicationRecord
    has_many :reviews, dependent: :destroy
    has_many :shop_owner, dependent: :destroy
    has_many :owners, through: :shop_owners, source: :user
    has_many :menu_items, dependent: :destroy   
    has_many :verifications, dependent: :destroy
    
    validates :name, presence: true
    validates :address, presence: true
    
    validates :name, uniqueness: { scope: :address, message: "この店舗はすでに登録されています" }
    
end
