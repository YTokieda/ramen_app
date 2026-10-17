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

  ROLES = { "owner" => "オーナー（経営者）", "manager" => "店長", "staff" => "スタッフ" }.freeze
  # 審査が終わってからこの期間がたった営業許可証は削除する
  LICENSE_RETENTION = 90.days

  normalizes :applicant_name, with: ->(v) { v.to_s.strip }
  # 全角の数字やハイフンも受け付ける
  normalizes :shop_phone, with: ->(v) { v.to_s.tr("０-９", "0-9").gsub(/[－ー―‐]/, "-").gsub(/[\s()（）]/, "") }

  # 申請フォームから送られたときに必須（以前からある申請には求めない）
  with_options on: :application do
    validates :applicant_name, presence: true, length: { maximum: 50 }
    validates :applicant_role, inclusion: { in: ROLES.keys, message: "を選んでください" }
    validates :shop_phone, format: { with: /\A0\d{1,4}-?\d{1,4}-?\d{3,4}\z/,
                                     message: "は 03-1234-5678 のような形で入力してください" }
    validate :business_license_attached
  end

  def role_label
    ROLES[applicant_role]
  end

  # 審査から一定期間たった営業許可証を削除する（氏名などの申請記録は残す）
  def self.purge_expired_licenses!
    where.not(status: "pending").where(reviewed_at: ...LICENSE_RETENTION.ago)
         .joins(:business_license_attachment).find_each do |shop_owner|
      shop_owner.business_license.purge
    end
  end

    LICENSE_CONTENT_TYPES = %w[
      image/jpeg
      image/png
      image/webp
      application/pdf
    ].freeze
  
    MAX_LICENSE_SIZE = 5.megabytes
  
  validate :acceptable_business_license
  
  private

    def business_license_attached
      errors.add(:business_license, "を添付してください") unless business_license.attached?
    end
  
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
