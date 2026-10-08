require "test_helper"

class MenuItemsControllerTest < ActionDispatch::IntegrationTest
  def setup
    @user = users(:michael)
    @shop = shops(:one)
  end

  test "should get new when logged in" do
    log_in_as(@user)

    get new_shop_menu_item_path(@shop)

    assert_response :success
  end
  
  test "logged in user should create menu item" do
    log_in_as(@user)
    
    assert_difference "MenuItem.count", 1 do
    post shop_menu_items_path(@shop),
         params: {
           menu_item: {
             name: "味噌ラーメン",
             description: "濃厚味噌ラーメン"
           }
         }
    end
    
    menu_item = MenuItem.order(:created_at).last
    
    assert_equal @shop, menu_item.shop
    assert_equal "味噌ラーメン", menu_item.name
    
    assert_redirected_to @shop

  end
  
  
  test "not logged in user should not create menu item" do
    assert_no_difference "MenuItem.count" do
      post shop_menu_items_path(@shop),
           params: {
             menu_item: {
               name: "味噌ラーメン",
               description: "濃厚味噌ラーメン"
             }
           }
    end
  
    assert_redirected_to login_url
  end
  
  test "should not create duplicate menu item in same shop" do
    log_in_as(@user)
  
    existing_menu_item = menu_items(:one)
  
    assert_no_difference "MenuItem.count" do
      post shop_menu_items_path(@shop),
           params: {
             menu_item: {
               name: existing_menu_item.name,
               description: "重複登録テスト"
             }
           }
    end
  
    assert_response :unprocessable_entity
  end
  
  test "should allow same menu item name in different shop" do
    log_in_as(@user)
  
    other_shop = shops(:two)
    existing_menu_item = menu_items(:one)
  
    assert_difference "MenuItem.count", 1 do
      post shop_menu_items_path(other_shop),
           params: {
             menu_item: {
               name: existing_menu_item.name,
               description: "別店舗の同名メニュー"
             }
           }
    end
  
    menu_item = MenuItem.order(:created_at).last
  
    assert_equal other_shop, menu_item.shop
    assert_equal existing_menu_item.name, menu_item.name
  end
  
  test "user should not override shop id" do
    log_in_as(@user)
  
    other_shop = shops(:two)
  
    assert_difference "MenuItem.count", 1 do
      post shop_menu_items_path(@shop),
           params: {
             menu_item: {
               name: "塩バターラーメン",
               description: "shop_id改ざんテスト",
               shop_id: other_shop.id
             }
           }
    end
  
    menu_item = MenuItem.order(:created_at).last
  
    assert_equal @shop, menu_item.shop
    assert_not_equal other_shop, menu_item.shop
  end
  
end