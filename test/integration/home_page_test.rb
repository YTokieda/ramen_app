require "test_helper"

class HomePageTest < ActionDispatch::IntegrationTest
  test "guest sees search, safety notice and signup link" do
    get root_path
    assert_response :success
    assert_select "form[action=?]", shops_path
    assert_select ".home-notice", /安全を保証するものではありません/
    assert_select "a[href=?]", signup_path
    assert_select "a#logo .logo-ribbon", "卵アレルギーの方向けのラーメン屋ガイド"
    assert_select "a#logo .logo-main", "たまナビ"
    assert_select "a#logo img.logo-icon"
  end

  test "logged in user sees contribution links instead of signup" do
    log_in_as(users(:michael))
    get root_path
    assert_select "a[href=?]", new_shop_submission_path
    assert_select "a[href=?]", signup_path, count: 0
  end

  test "admin sees link to pending verifications in header" do
    log_in_as(users(:michael))
    get root_path
    assert_select "#admin-dropdown-menu a[href=?]", admin_verifications_path
  end

  test "non-admin does not see admin menu" do
    log_in_as(users(:archer))
    get root_path
    assert_select "#admin-dropdown-menu", count: 0
  end

  test "recent verifications do not include pending information" do
    shop = Shop.create!(name: "確認待ちテスト店", address: "東京都テスト区1-1")
    menu_item = shop.menu_items.create!(name: "テストラーメン")
    Verification.create!(shop: shop, menu_item: menu_item, user: users(:archer),
                         category: "noodle_soup", egg_status: "egg_free",
                         source_type: "user_report", verification_method: "電話",
                         verified_on: Date.current, status: "pending")

    get root_path
    assert_select ".home-recent", text: /確認待ちテスト店/, count: 0
  end
end
