class ReviewReply < ApplicationRecord
  belongs_to :review
  belongs_to :shop_owner
  
  validates :content, presence: true, length: { maximum: 2000 }
  validates :review_id, uniqueness: true
end
