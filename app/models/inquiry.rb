class Inquiry < ApplicationRecord
  belongs_to :user, optional: true

  CATEGORIES = {
    "wrong_info"   => "掲載情報の誤り・変更",
    "shop"         => "店舗の方から",
    "review"       => "口コミの削除依頼",
    "privacy"      => "個人情報・退会について",
    "other"        => "その他"
  }.freeze

  STATUSES = {
    "new"         => "未対応",
    "in_progress" => "対応中",
    "closed"      => "対応済み"
  }.freeze

  validates :category, inclusion: { in: CATEGORIES.keys }
  validates :name, presence: true, length: { maximum: 50 }
  validates :email, presence: true, length: { maximum: 255 },
                    format: { with: User::VALID_EMAIL_REGEX }
  validates :body, presence: true, length: { maximum: 2000 }
  validates :status, inclusion: { in: STATUSES.keys }

  def category_label
    I18n.t("inquiries.categories.#{category}", default: CATEGORIES[category])
  end

  def status_label
    STATUSES[status]
  end
end
