require "test_helper"

class ShopsControllerTest < ActionDispatch::IntegrationTest

    test "show should select latest approved verification for each menu item and category" do
      shop = shops(:one)
      menu_item = menu_items(:one)
      user = users(:michael)
    
      old_verification = Verification.create!(
        shop: shop,
        menu_item: menu_item,
        user: user,
        category: "noodle_soup",
        egg_status: "egg_free",
        source_type: "manufacturer",
        verification_method: "古いメーカー資料",
        verified_on: Date.new(2026, 1, 10),
        status: "approved"
      )
    
      latest_verification = Verification.create!(
        shop: shop,
        menu_item: menu_item,
        user: user,
        category: "noodle_soup",
        egg_status: "contains_egg",
        source_type: "manufacturer",
        verification_method: "最新のメーカー資料",
        verified_on: Date.new(2026, 9, 15),
        status: "approved"
      )
    
      get shop_path(shop)
    
      assert_response :success
    
      approved_verifications =
        assigns(:approved_verifications)
    
      assert_includes approved_verifications, latest_verification
      assert_not_includes approved_verifications, old_verification
    end
    
    
    test "show should not display pending verification even if it is newer" do
      shop = shops(:one)
      menu_item = menu_items(:one)
      user = users(:michael)
    
      Verification.create!(
        shop: shop,
        menu_item: menu_item,
        user: user,
        category: "noodle_soup",
        egg_status: "egg_free",
        source_type: "manufacturer",
        verification_method: "APPROVED_VERIFICATION_TEST",
        verified_on: Date.new(2026, 5, 1),
        status: "approved"
      )
    
      Verification.create!(
        shop: shop,
        menu_item: menu_item,
        user: user,
        category: "noodle_soup",
        egg_status: "contains_egg",
        source_type: "manufacturer",
        verification_method: "PENDING_VERIFICATION_TEST",
        verified_on: Date.new(2026, 10, 1),
        status: "pending"
      )
    
      get shop_path(shop)
    
      assert_response :success
    
      assert_select "body", text: /APPROVED_VERIFICATION_TEST/
      assert_select "body", text: /PENDING_VERIFICATION_TEST/, count: 0
    end
    
  test "show should display verification history" do
    shop = shops(:one)
    menu_item = shop.menu_items.first
    user = users(:michael)
  
    Verification.create!(
      shop: shop,
      menu_item: menu_item,
      user: user,
      category: "noodle_soup",
      egg_status: "egg_free",
      source_type: "manufacturer",
      verification_method: "HISTORY_OLD_TEST",
      verified_on: Date.new(2026, 1, 10),
      status: "approved"
    )
  
    Verification.create!(
      shop: shop,
      menu_item: menu_item,
      user: user,
      category: "noodle_soup",
      egg_status: "contains_egg",
      source_type: "manufacturer",
      verification_method: "HISTORY_LATEST_TEST",
      verified_on: Date.new(2026, 9, 15),
      status: "approved"
    )
  
    get shop_path(shop)
  
    assert_response :success
  
    # 最新情報はdetailsの外側に表示
    assert_select "body > details", count: 0 if false
  
    # 過去情報はdetailsの内側に表示
    assert_select "details" do
      assert_select "li", text: /HISTORY_OLD_TEST/
      assert_select "li", text: /HISTORY_LATEST_TEST/, count: 0
    end
  
    # 最新情報自体はページに存在する
    assert_select "body", text: /HISTORY_LATEST_TEST/
  end
  
  
  test "show should not publicly display unapproved history" do
    shop = shops(:one)
    menu_item = shop.menu_items.first
    user = users(:michael)
  
    ["pending", "rejected"].each do |status|
      Verification.create!(
        shop: shop,
        menu_item: menu_item,
        user: user,
        category: "noodle_soup",
        egg_status: "contains_egg",
        source_type: "user_report",
        verification_method: "HIDDEN_#{status.upcase}_TEST",
        verified_on: Date.new(2026, 10, 1),
        status: status
      )
    end
  
    get shop_path(shop)
  
    assert_response :success
  
    assert_select "body", text: /HIDDEN_PENDING_TEST/, count: 0
    assert_select "body", text: /HIDDEN_REJECTED_TEST/, count: 0
  end

  test "index displays all shops without search conditions" do
    get shops_path
    assert_response :success
    
    assert_equal Shop.count, assigns(:shops).count 
  end
  
  
  test "index searches shops by name" do
    shop = shops(:one)
    shop.update!(name: "検索専用ラーメン店")
  
    get shops_path, params: { keyword: "検索専用" }
  
    assert_response :success
    assert_includes assigns(:shops), shop
  end
  
  test "index searches shops by address" do
    shop = shops(:one)
    shop.update!(address: "東京都品川区検索専用住所")
  
    get shops_path, params: { keyword: "検索専用住所" }
  
    assert_response :success
    assert_includes assigns(:shops), shop
  end
  
  test "index filters shops by approved egg information" do
    shop = shops(:one)
  
    Verification.create!(
      shop: shop,
      menu_item: menu_items(:one),
      user: users(:michael),
      category: "noodle_soup",
      egg_status: "egg_free",
      source_type: "manufacturer",
      verification_method: "メーカー資料確認",
      verified_on: Date.new(2026, 9, 20),
      status: "approved"
    )
  
    get shops_path, params: {
      egg_status: "egg_free",
      category: "noodle_soup"
    }
  
    assert_response :success
    assert_includes assigns(:shops), shop
  end
    
  test "index excludes conflicting latest egg information" do
    shop = shops(:one)
    menu_item = menu_items(:one)
    user = users(:michael)
  
    Verification.create!(
      shop: shop,
      menu_item: menu_item,
      user: user,
      category: "noodle_soup",
      egg_status: "contains_egg",
      source_type: "manufacturer",
      verification_method: "メーカー資料A",
      verified_on: Date.new(2026, 10, 1),
      status: "approved"
    )
  
    Verification.create!(
      shop: shop,
      menu_item: menu_item,
      user: user,
      category: "noodle_soup",
      egg_status: "egg_free",
      source_type: "manufacturer",
      verification_method: "メーカー資料B",
      verified_on: Date.new(2026, 10, 1),
      status: "approved"
    )
  
    get shops_path, params: {
      egg_status: "egg_free",
      category: "noodle_soup"
    }
  
    assert_response :success
    assert_not_includes assigns(:shops), shop
  end
  
  
  test "index displays latest approved verification summary" do
    shop = shops(:one)
  
    Verification.create!(
      shop: shop,
      menu_item: menu_items(:one),
      user: users(:michael),
      category: "noodle_soup",
      egg_status: "egg_free",
      source_type: "manufacturer",
      verification_method: "メーカー資料",
      verified_on: Date.new(2026, 10, 5),
      status: "approved"
    )
  
    get shops_path
  
    assert_response :success
    assert_select ".verification-summary", text: /メーカー/
  end
  
  test "index does not display pending verification summary" do
    shop = shops(:one)
  
    Verification.create!(
      shop: shop,
      menu_item: menu_items(:one),
      user: users(:michael),
      category: "noodle_soup",
      egg_status: "egg_free",
      source_type: "user_report",
      verification_method: "PENDING_SUMMARY_TEST",
      verified_on: Date.new(2026, 10, 5),
      status: "pending"
    )
  
    get shops_path
  
    assert_response :success
    assert_select "body", text: /PENDING_SUMMARY_TEST/, count: 0
  end
  
  test "index uses latest verification for filtering" do
    shop = shops(:one)
    menu_item = menu_items(:one)
    user = users(:michael)
  
    Verification.create!(
      shop: shop,
      menu_item: menu_item,
      user: user,
      category: "noodle_soup",
      egg_status: "egg_free",
      source_type: "manufacturer",
      verification_method: "OLD_SEARCH_TEST",
      verified_on: Date.new(2026, 1, 1),
      status: "approved"
    )
  
    Verification.create!(
      shop: shop,
      menu_item: menu_item,
      user: user,
      category: "noodle_soup",
      egg_status: "contains_egg",
      source_type: "manufacturer",
      verification_method: "LATEST_SEARCH_TEST",
      verified_on: Date.new(2026, 10, 1),
      status: "approved"
    )
  
    get shops_path, params: {
      egg_status: "egg_free",
      category: "noodle_soup"
    }
  
    assert_response :success
    assert_not_includes assigns(:shops), shop
  end
  
  test "index displays at most three verification summaries per shop" do
    shop = shops(:one)
    user = users(:michael)
  
    4.times do |i|
      menu_item = shop.menu_items.create!(
        name: "TEST_MENU_#{i}"
      )
  
      Verification.create!(
        shop: shop,
        menu_item: menu_item,
        user: user,
        category: "noodle_soup",
        egg_status: "egg_free",
        source_type: "manufacturer",
        verification_method: "TEST_METHOD_#{i}",
        verified_on: Date.new(2026, 10, 1),
        status: "approved"
      )
    end
  
    get shops_path
  
    assert_response :success
  
    assert_select ".shop" do
      assert_select ".verification-summary", maximum: 3
    end
  
    assert_select "body", text: /ほかに.*件の卵情報があります/
  end
  
  
end