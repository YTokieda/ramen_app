class ShopSubmission < ApplicationRecord
  belongs_to :user
  
  validates :name, presence: true
  validates :address, presence: true
  
  validates :status,
            inclusion: { in: %w[pending approved rejected] }
  
end
