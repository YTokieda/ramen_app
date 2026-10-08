require "test_helper"

class Admin::ShopOwnersControllerTest < ActionDispatch::IntegrationTest

  def setup
    @admin = users(:michael)
    @user  = users(:archer)
    @shop  = shops(:one)

    @shop_owner = ShopOwner.create!(
      user: @user,
      shop: @shop,
      status: "pending"
    )
  end

  test "non admin user should not access shop owner applications" do
    log_in_as(@user)
    get admin_shop_owners_path
    assert_redirected_to root_url
  end

  test "admin should approve shop owner" do
     log_in_as(@admin)
     patch approve_admin_shop_owner_path(@shop_owner)
     @shop_owner.reload
     
     assert_equal "approved", @shop_owner.status
     assert_redirected_to admin_shop_owners_path
  end

  test "admin should reject shop owner" do
    log_in_as(@admin)

    patch reject_admin_shop_owner_path(@shop_owner)

    @shop_owner.reload

    assert_equal "rejected", @shop_owner.status
    assert_redirected_to admin_shop_owners_path
  end

  test "approved shop owner should not be processed again" do
    log_in_as(@admin)

    patch approve_admin_shop_owner_path(@shop_owner)

    @shop_owner.reload
    assert_equal "approved", @shop_owner.status

    patch reject_admin_shop_owner_path(@shop_owner)

    @shop_owner.reload
    assert_equal "approved", @shop_owner.status
  end
end