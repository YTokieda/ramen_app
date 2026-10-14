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

    LICENSE_CONTENT_TYPES = %w[
      image/jpeg
      image/png
      image/webp
      application/pdf
    ].freeze
  
    MAX_LICENSE_SIZE = 5.megabytes
  
  validate :acceptable_business_license
  
  private
  
    def acceptable_business_license
      return unless business_license.attached?
  
      blob = business_license.blob
  
      unless LICENSE_CONTENT_TYPES.include?(blob.content_type)
        errors.add(
          :business_license,
          "はJPEG、PNG、WebP、PDFのみ添付できます"
        )
      end
  
      if blob.byte_size > MAX_LICENSE_SIZE
        errors.add(
          :business_license,
          "は5MB以下にしてください"
        )
      end
    end

end
