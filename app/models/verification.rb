class Verification < ApplicationRecord
  belongs_to :shop
  belongs_to :menu_item, optional: true
  belongs_to :user
  has_many_attached :evidence_files

  EVIDENCE_CONTENT_TYPES = %w[
    image/jpeg
    image/png
    image/webp
    application/pdf
  ].freeze
  
  MAX_EVIDENCE_FILES = 3
  MAX_EVIDENCE_SIZE = 5.megabytes
  
  validate :validate_evidence_files
    

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
  validates :verification_method, presence: true

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
  
  def validate_evidence_files
    return unless evidence_files.attached?
  
    if evidence_files.size > MAX_EVIDENCE_FILES
      errors.add(
        :evidence_files,
        "は最大#{MAX_EVIDENCE_FILES}ファイルまでです"
      )
    end
  
    evidence_files.each do |file|
      blob = file.blob
  
      unless EVIDENCE_CONTENT_TYPES.include?(blob.content_type)
        errors.add(
          :evidence_files,
          "はJPEG、PNG、WebP、PDFのみ添付できます"
        )
      end
  
      if blob.byte_size > MAX_EVIDENCE_SIZE
        errors.add(
          :evidence_files,
          "は1ファイル5MB以下にしてください"
        )
      end
    end
  end
  
end