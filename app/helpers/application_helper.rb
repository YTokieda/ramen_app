module ApplicationHelper
  SITE_NAME = "卵アレルギー対応ラーメンガイド".freeze
  SITE_NAME_EN = "EGG ALLERGY RAMEN GUIDE".freeze

  def site_name
    SITE_NAME
  end

  def site_name_en
    SITE_NAME_EN
  end

  def full_title(page_title = '')
    if page_title.empty?
      SITE_NAME
    else
      page_title + " | " + SITE_NAME
    end
  end
end
