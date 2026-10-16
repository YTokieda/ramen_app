require "test_helper"

class ShopOwnerNavTest < ActionDispatch::IntegrationTest
  test "shop management link is hidden for users who are not shop owners" do
    log_in_as(users(:archer))
    get root_path
    assert_select "a[href=?]", dashboard_shop_owners_path, count: 0
  end

  test "shop management link is hidden while the owner request is pending" do
    shop_owners(:one).update_columns(status: "pending")
    log_in_as(users(:michael))
    get root_path
    assert_select "a[href=?]", dashboard_shop_owners_path, count: 0
  end

  test "shop management link is shown for approved shop owners" do
    shop_owners(:one).update_columns(status: "approved")
    log_in_as(users(:michael))
    get root_path
    assert_select "a[href=?]", dashboard_shop_owners_path
  end
end
