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

  def egg_status_badge(egg_status)
    content_tag(:span, egg_status_label(egg_status),
                class: "egg-badge egg-badge--#{egg_status}")
  end

  def egg_status_conflict_badge
    content_tag(:span, "情報に食い違いあり",
                class: "egg-badge egg-badge--conflict")
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
  
  def verification_freshness_label(verified_on)
    return "確認日不明" if verified_on.blank?
  
    if verified_on <= 12.months.ago.to_date
      "確認から1年以上経過しています。店舗への再確認をおすすめします。"
    elsif verified_on <= 6.months.ago.to_date
      "確認から6か月以上経過しています。情報が変更されている可能性があります。"
    else
      nil
    end
  end
  

  def verification_same_day_status(verification, histories)
    same_day_verifications = histories.select do |history|
      history.verified_on == verification.verified_on
    end
  
    statuses = (
      [verification] + same_day_verifications
    ).map(&:egg_status).uniq
  
    if statuses.include?("egg_free") &&
       statuses.include?("contains_egg")
      :conflict
    elsif statuses.include?("unknown") && statuses.size > 1
      :uncertain
    else
      :consistent
    end
  end
  
  def verification_history_status(verification, histories)
    previous = histories
      .select { |history| history.verified_on < verification.verified_on }
      .max_by { |history| [history.verified_on, history.created_at || Time.at(0)] }
  
    return :consistent if previous.nil?
  
    statuses = [verification.egg_status, previous.egg_status]
  
    if statuses.include?("unknown")
      statuses.uniq.size > 1 ? :uncertain : :consistent
    elsif statuses.uniq.size > 1
      :changed
    else
      :consistent
    end
  end
  
    
end