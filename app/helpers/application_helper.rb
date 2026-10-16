module ApplicationHelper
  SITE_NAME = "卵アレルギーの方のためのラーメンガイド".freeze
  SITE_NAME_EN = "EGG ALLERGY RAMEN GUIDE".freeze
  OPERATOR_NAME = "TOK Works".freeze
  CONTACT_EMAIL = "contact@tokworks.jp".freeze

  def site_name
    I18n.t("site.name")
  end

  def site_name_en
    SITE_NAME_EN
  end

  def operator_name
    OPERATOR_NAME
  end

  def contact_email
    CONTACT_EMAIL
  end

  def full_title(page_title = '')
    if page_title.empty?
      site_name
    else
      page_title + " | " + site_name
    end
  end

  # 表示中のページを別の言語で開くリンク先（GET以外の画面ではトップへ）
  def switch_locale_path(locale)
    target = locale.to_sym == I18n.default_locale ? nil : locale
    if request.get?
      url_for(request.path_parameters.merge(request.query_parameters).merge(locale: target, only_path: true))
    else
      root_path(locale: target)
    end
  end
end
