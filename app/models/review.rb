class Review < ApplicationRecord
  belongs_to :user
  belongs_to :shop
  
  has_many_attached :images
  validates :content, presence: true
  
  validate :acceptable_images
  
  private
  
  def acceptable_images
    return unless images.attached?

    if images.size > 3
      errors.add(:images, "は3枚まで投稿できます")
    end

    images.each do |image|
      unless image.content_type.in?(%w[image/jpeg image/png image/webp])
        errors.add(:images, "はJPEG・PNG・WebPのみ投稿できます")
      end

      if image.byte_size > 5.megabytes
        errors.add(:images, "は1枚5MB以下にしてください")
      end
    end
  end
end

