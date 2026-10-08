class Verification < ApplicationRecord
  belongs_to :shop
  belongs_to :menu_item, optional: true
  belongs_to :user

  CATEGORIES = %w[
    noodle_soup
    topping
    cooking_environment
  ].freeze

  EGG_STATUSES = %w[
    egg_free
    contains_egg
    unknown
  ].freeze

  SOURCE_TYPES = %w[
    official
    shop_owner
    staff
    manufacturer
    user_report
  ].freeze
  
  STATUSES = %w[
    pending
    approved
    rejected
  ].freeze

  validates :category,
            presence: true,
            inclusion: { in: CATEGORIES }

  validates :egg_status,
            presence: true,
            inclusion: { in: EGG_STATUSES }

  validates :source_type,
            presence: true,
            inclusion: { in: SOURCE_TYPES }
            
  validates :status,
            presence: true,
            inclusion: { in: STATUSES }

  validates :verified_on, presence: true

  validate :menu_item_belongs_to_shop
  validate :category_matches_menu_item

  private

  def menu_item_belongs_to_shop
    return if menu_item.nil?

    if menu_item.shop_id != shop_id
      errors.add(:menu_item, "はこの店舗のメニューではありません")
    end
  end
  
  def category_matches_menu_item
    if category == "cooking_environment"
      if menu_item.present?
        errors.add(:menu_item, "は調理環境の情報には設定できません")
      end
    elsif CATEGORIES.include?(category)
      if menu_item.nil?
        errors.add(:menu_item, "を選択してください")
      end
    end
  end
  
end