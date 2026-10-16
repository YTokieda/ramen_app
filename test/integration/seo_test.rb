require "test_helper"

class SeoTest < ActionDispatch::IntegrationTest
  test "shop page has its own title, description, OGP and structured data" do
    shop = shops(:one)
    get shop_path(shop)
    assert_select "title", text: /#{Regexp.escape(shop.name)}/
    assert_select "meta[name=description][content*=?]", shop.name
    assert_select "meta[property='og:title'][content*=?]", shop.name
    assert_select "meta[property='og:image'][content*=?]", "og-image"
    assert_select "link[rel=canonical][href$=?]", shop_path(shop)
    assert_select "link[rel=alternate][hreflang=en]"
    assert_select "script[type='application/ld+json']", text: /Restaurant/
    assert_select "meta[name=robots]", count: 0
  end

  test "login and admin pages are not indexed" do
    get login_path
    assert_select "meta[name=robots][content=noindex]"
    get user_path(users(:michael))
    assert_select "meta[name=robots][content=noindex]"
  end

  test "home page has the default description" do
    get root_path
    assert_select "meta[name=description][content*=?]", "卵アレルギー"
  end

  test "robots.txt points to the sitemap and blocks admin" do
    get "/robots.txt"
    assert_response :success
    assert_match "Disallow: /admin/", response.body
    assert_match %r{Sitemap: http.*/sitemap.xml}, response.body
  end

  test "sitemap lists visible shops in both languages but not hidden ones" do
    hidden = shops(:two)
    hidden.update_columns(hidden_at: Time.current)
    get "/sitemap.xml"
    assert_response :success
    assert_equal "application/xml", response.media_type
    assert_match %r{<loc>http[^<]*/shops/#{shops(:one).id}</loc>}, response.body
    assert_match %r{<loc>http[^<]*/en/shops/#{shops(:one).id}</loc>}, response.body
    assert_no_match %r{/shops/#{hidden.id}<}, response.body
  end
end
