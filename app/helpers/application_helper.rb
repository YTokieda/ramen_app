module ApplicationHelper
  SITE_NAME = "卵アレルギー ラーメン情報".freeze

  def site_name
    SITE_NAME
  end

  def full_title(page_title = '')
    if page_title.empty?
      SITE_NAME
    else
      page_title + " | " + SITE_NAME
    end
  end
end
