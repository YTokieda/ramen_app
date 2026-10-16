module VerificationsHelper
  def verification_category_label(category)
    t("verification.categories.#{category}", default: category.to_s)
  end

  def egg_status_badge(egg_status)
    content_tag(:span, egg_status_label(egg_status),
                class: "egg-badge egg-badge--#{egg_status}")
  end

  def egg_status_conflict_badge
    content_tag(:span, t("verification.egg_statuses.conflict"),
                class: "egg-badge egg-badge--conflict")
  end

  def egg_status_label(egg_status)
    t("verification.egg_statuses.#{egg_status}", default: egg_status.to_s)
  end

  def verification_source_label(source_type)
    t("verification.sources.#{source_type}", default: source_type.to_s)
  end

  def verification_status_label(status)
    t("verification.statuses.#{status}", default: status.to_s)
  end

  def verification_freshness_label(verified_on)
    return t("verification.freshness.unknown") if verified_on.blank?

    if verified_on <= 12.months.ago.to_date
      t("verification.freshness.over_year")
    elsif verified_on <= 6.months.ago.to_date
      t("verification.freshness.over_half_year")
    else
      nil
    end
  end

  def verification_target_name(verification)
    verification.menu_item&.name || t("verification.cooking_environment_target")
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