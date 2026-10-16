class Shop < ApplicationRecord
    has_many :reviews, dependent: :destroy
    has_many :shop_owner, dependent: :destroy
    has_many :owners, through: :shop_owners, source: :user
    has_many :menu_items, dependent: :destroy   
    has_many :verifications, dependent: :destroy
    
    validates :name, presence: true, length: { maximum: 100 }
    validates :address, presence: true, length: { maximum: 200 }
    validates :description, length: { maximum: 5000 }
    
    validates :name, uniqueness: { scope: :address, message: "この店舗はすでに登録されています" }

    # 運営が非公開にした店舗は、一般の利用者には見せない
    scope :visible, -> { where(hidden_at: nil) }

    def hidden?
      hidden_at.present?
    end
    
    def self.search(keyword:, egg_status:, category:)
      shops = visible
    
      # 店舗名・住所による検索
      if keyword.present?
        pattern = "%#{sanitize_sql_like(keyword.strip)}%"
    
        shops = shops.where(
          "shops.name LIKE :keyword OR shops.address LIKE :keyword",
          keyword: pattern
        )
      end
    
      # 卵情報・確認項目による絞り込み
      if egg_status.present? || category.present?
        groups = latest_verification_groups
    
        matching_groups = groups.select do |group|
          verification = group[:verification]
    
          # 矛盾がある情報は検索条件に一致させない
          next false if group[:conflicting]
    
          category_matches =
            category.blank? || verification.category == category
    
          egg_status_matches =
            egg_status.blank? || verification.egg_status == egg_status
    
          category_matches && egg_status_matches
        end
    
        shop_ids = matching_groups.map do |group|
          group[:verification].shop_id
        end.uniq
    
        shops = shops.where(id: shop_ids)
      end
    
      shops.order(:name, :id)
    end
   
    def self.latest_verification_groups
      approved = Verification
        .where(status: "approved")
        .includes(:menu_item)
        .order(verified_on: :desc, created_at: :desc, id: :desc)
    
      approved
        .group_by { |v| [v.shop_id, v.menu_item_id, v.category] }
        .values
        .map do |history|
          newest_date = history.first.verified_on
    
          same_date = history.select do |v|
            v.verified_on == newest_date
          end
    
          statuses = same_date.map(&:egg_status).uniq
    
          {
            verification: history.first,
            conflicting: statuses.size > 1
          }
        end
    end

end
