require "test_helper"

class MenuItemEditTest < ActionDispatch::IntegrationTest
  def setup
    @shop = shops(:one)
    @menu_item = menu_items(:one)
    @owner = users(:archer)
    ShopOwner.new(user: @owner, shop: @shop, status: "approved").save!(validate: false)
  end

  test "approved owner can rename a menu item and sees links on the dashboard" do
    log_in_as(@owner)
    get dashboard_shop_owners_path
    assert_select "a[href=?]", edit_shop_menu_item_path(@shop, @menu_item)
    assert_select "a[href=?]", new_shop_menu_item_path(@shop)

    get edit_shop_menu_item_path(@shop, @menu_item)
    assert_response :success
    patch shop_menu_item_path(@shop, @menu_item),
          params: { menu_item: { name: "醤油ラーメン（並）", description: "説明" } }
    assert_redirected_to shop_path(@shop)
    assert_equal "醤油ラーメン（並）", @menu_item.reload.name
  end

  test "other users cannot edit menu items" do
    log_in_as(users(:lana))
    get edit_shop_menu_item_path(@shop, @menu_item)
    assert_redirected_to shop_path(@shop)
    patch shop_menu_item_path(@shop, @menu_item), params: { menu_item: { name: "いたずら" } }
    assert_not_equal "いたずら", @menu_item.reload.name
  end

  test "owner of another shop cannot edit this shop's menu" do
    log_in_as(@owner)
    other = menu_items(:two)
    patch shop_menu_item_path(other.shop, other), params: { menu_item: { name: "いたずら" } }
    assert_not_equal "いたずら", other.reload.name
  end

  test "menu item must belong to the shop in the URL" do
    log_in_as(@owner)
    other = menu_items(:two)
    patch shop_menu_item_path(@shop, other), params: { menu_item: { name: "いたずら" } }
    assert_response :not_found
  end

  test "pending owner cannot edit" do
    log_in_as(users(:michael))
    shop_owners(:one).update_columns(status: "pending")
    users(:michael).update_columns(admin: false)
    patch shop_menu_item_path(@shop, @menu_item), params: { menu_item: { name: "いたずら" } }
    assert_not_equal "いたずら", @menu_item.reload.name
  end
end
