module VerificationsHelper
  def verification_category_label(category)
    case category
    when "noodle_soup"
      "麺およびスープ"
    when "topping"
      "トッピング（味玉以外）"
    when "cooking_environment"
      "調理環境"
    else
      category
    end
  end

  def egg_status_label(egg_status)
    case egg_status
    when "egg_free"
      "卵不使用を確認"
    when "contains_egg"
      "卵を使用"
    when "unknown"
      "未確認"
    else
      egg_status
    end
  end

  def verification_source_label(source_type)
    case source_type
    when "official"
      "店舗公式情報"
    when "shop_owner"
      "店舗オーナー"
    when "staff"
      "店舗スタッフ"
    when "manufacturer"
      "メーカー"
    when "user_report"
      "ユーザー報告"
    else
      source_type
    end
  end

  def verification_status_label(status)
    case status
    when "pending"
      "運営確認待ち"
    when "approved"
      "運営確認済み"
    when "rejected"
      "却下"
    else
      status
    end
  end
end