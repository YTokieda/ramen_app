class ShopSubmission < ApplicationRecord
  belongs_to :user
  
  validates :name, presence: true, length: { maximum: 100 }
  validates :address, presence: true, length: { maximum: 200 }
  validates :description, length: { maximum: 2000 }
  
  validates :status,
            inclusion: { in: %w[pending approved rejected] }
  
end
