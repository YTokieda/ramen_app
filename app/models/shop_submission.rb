class ShopSubmission < ApplicationRecord
  belongs_to :user
  
  validates :name, presence: true, length: { maximum: 100 }
  validates :address, presence: true, length: { maximum: 200 }
  validates :description, length: { maximum: 2000 }
  validates :website_url, length: { maximum: 500 }, http_url: true
  normalizes :website_url, with: ->(url) { url.strip.presence }
  
  validates :status,
            inclusion: { in: %w[pending approved rejected] }
  
end
