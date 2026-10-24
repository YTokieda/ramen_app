require "test_helper"

class LegalAndLocaleTest < ActionDispatch::IntegrationTest
  test "privacy policy shows operator and contact" do
    get privacy_path
    assert_response :success
    assert_select "title", "プライバシーポリシー | みんなのラーメン"
    assert_match "TOK Works", response.body
    assert_select "a[href=?]", "mailto:ramen-guide@tokworks.jp"
    assert_match "外国にある事業者", response.body
  end

  test "terms of use include the allergy safety notice" do
    get terms_path
    assert_response :success
    assert_match "安全を保証するものではありません", response.body
  end

  test "footer links to legal pages" do
    get root_path
    assert_select "footer a[href=?]", privacy_path
    assert_select "footer a[href=?]", terms_path
  end

  test "japanese is the default and links to english" do
    get root_path
    assert_select "html[lang=ja]"
    assert_select ".locale-switch a[href=?]", "/en"
  end

  test "english home page" do
    get "/en"
    assert_response :success
    assert_select "html[lang=en]"
    assert_select ".ribbon", "Egg allergy ramen guide"
    assert_select "a#logo .logo-main", "Minna no Ramen"
    assert_select "title", /Minna no Ramen/
    assert_select ".locale-switch a[href=?]", "/"
    # 英語ページ内のリンクは英語のまま
    assert_select "a[href=?]", "/en/shops"
  end

  test "english shop list and detail" do
    get "/en/shops"
    assert_response :success
    assert_select "h1", "Find ramen shops"
    assert_match "does not guarantee safety", response.body

    shop = shops(:one) rescue Shop.first
    get "/en/shops/#{shop.id}"
    assert_response :success
    assert_select "h2", "Egg information"
  end

  test "english legal pages note that japanese prevails" do
    get "/en/privacy"
    assert_response :success
    assert_match "Japanese version", response.body
    get "/en/terms"
    assert_response :success
    assert_select "h1", "Terms of Use"
  end

  test "english contact form" do
    get "/en/contact"
    assert_response :success
    assert_select "label", "Topic"
    assert_select "option", "Review removal request"
  end

  test "switch link keeps the current page and query" do
    get shops_path(keyword: "新宿")
    assert_select ".locale-switch a[href=?]", "/en/shops?keyword=%E6%96%B0%E5%AE%BF"
  end
end
