class ShopOwner < ApplicationRecord
  belongs_to :shop
  has_one_attached :business_license # ActiveStorageを利用
  has_secure_password

  before_save { email.downcase! }

  validates :name, presence: true
  validates :email, presence: true, uniqueness: true
  validates :password, length: { minimum: 6 }, allow_nil: true
  validates :business_license, presence: true

  # ネストフォーム対応（ShopOwner登録時にShopも登録可能）
  accepts_nested_attributes_for :shop

  before_validation :link_existing_or_build_shop

  private

  # オーナー登録時に既存店舗と紐づけ or 新規作成
  def link_existing_or_build_shop
    # shopが既に指定されていれば何もしない
    return if shop.present?

    # フォーム経由の値があるか確認（ネストフォーム想定）
    shop_name = self.shop_attributes&.dig("name")
    shop_address = self.shop_attributes&.dig("address")
    return if shop_name.blank? || shop_address.blank?

    # 既存店舗を検索
    existing_shop = Shop.find_by(name: shop_name, address: shop_address)

    if existing_shop
      self.shop = existing_shop
      errors.add(:base, "既存の店舗と紐づけられました") unless self.persisted?
    else
      self.build_shop(name: shop_name, address: shop_address)
    end
  end
end
