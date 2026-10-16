xml.instruct! :xml, version: "1.0", encoding: "UTF-8"
xml.urlset xmlns: "http://www.sitemaps.org/schemas/sitemap/0.9",
           "xmlns:xhtml" => "http://www.w3.org/1999/xhtml" do
  pages = [
    [root_path(locale: nil), root_path(locale: :en), nil],
    [shops_path(locale: nil), shops_path(locale: :en), nil],
    [about_path(locale: nil), about_path(locale: :en), nil],
    [help_path(locale: nil), help_path(locale: :en), nil],
    [privacy_path(locale: nil), privacy_path(locale: :en), nil],
    [terms_path(locale: nil), terms_path(locale: :en), nil]
  ]
  @shops.each do |shop|
    pages << [shop_path(shop, locale: nil), shop_path(shop, locale: :en), shop.updated_at]
  end

  pages.each do |ja, en, updated_at|
    [ja, en].each do |path|
      xml.url do
        xml.loc @base + path
        xml.lastmod updated_at.to_date.iso8601 if updated_at
        xml.tag! "xhtml:link", rel: "alternate", hreflang: "ja", href: @base + ja
        xml.tag! "xhtml:link", rel: "alternate", hreflang: "en", href: @base + en
      end
    end
  end
end
