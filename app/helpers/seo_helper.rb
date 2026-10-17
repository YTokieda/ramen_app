module SeoHelper
  # 検索結果に出してよいページ（それ以外はログイン画面や管理画面など）
  INDEXABLE_PAGES = %w[
    static_pages#home static_pages#about static_pages#help static_pages#privacy static_pages#terms
    shops#index shops#show inquiries#new
  ].freeze

  # 正式なドメインのURL（CANONICAL_HOST があればそちらを使う）
  def canonical_base_url
    host = ENV["CANONICAL_HOST"].presence
    host ? "https://#{host}" : request.base_url
  end

  def canonical_url
    path = url_for(request.path_parameters.merge(only_path: true))
    canonical_base_url + path
  end

  def page_description
    content_for?(:description) ? content_for(:description) : t("seo.default_description")
  end

  def indexable_page?
    return false if content_for?(:noindex)
    INDEXABLE_PAGES.include?("#{controller_path}##{action_name}") && request.query_parameters.empty?
  end

  # 日本語と英語の同じページのURL
  def alternate_locale_url(locale)
    target = locale.to_sym == I18n.default_locale ? nil : locale
    canonical_base_url + url_for(request.path_parameters.merge(locale: target, only_path: true))
  end

  # 店舗ページの説明文：卵不使用・卵使用が確認されたメニューを並べる
  def shop_meta_description(shop, verifications)
    names_for = lambda do |status|
      verifications.select { |v| v.egg_status == status }
                   .map { |v| v.menu_item&.name || t("verification.cooking_environment_target") }
                   .uniq.first(5)
    end
    parts = [t("seo.shop_lead", name: shop.name, address: shop.address)]
    egg_free = names_for.call("egg_free")
    contains = names_for.call("contains_egg")
    parts << t("seo.shop_egg_free", items: egg_free.join(t("seo.separator"))) if egg_free.any?
    parts << t("seo.shop_contains_egg", items: contains.join(t("seo.separator"))) if contains.any?
    parts << t("seo.shop_none") if egg_free.empty? && contains.empty?
    parts.join(t("seo.sentence_separator")).truncate(160)
  end

  def shop_structured_data(shop)
    data = {
      "@context" => "https://schema.org",
      "@type" => "Restaurant",
      "name" => shop.name,
      "address" => shop.address,
      "servesCuisine" => "Ramen",
      "url" => canonical_base_url + shop_path(shop)
    }
    data["sameAs"] = shop.website_url if shop.website_url.present?
    tag.script(data.to_json.html_safe, type: "application/ld+json")
  end

  def og_image_url
    canonical_base_url + image_path("og-image.jpg")
  end
end
