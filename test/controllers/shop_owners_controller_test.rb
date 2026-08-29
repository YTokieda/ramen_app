require "test_helper"

class ShopOwnersControllerTest < ActionDispatch::IntegrationTest
  test "should get new" do
    get new_shop_owner_url
    assert_response :success
  end

  # test "should get create" do
  #   post new_shop_owners_url
  #   assert_response :success
  # end

  # test "should get dashboard" do
  #   get shop_owners_dashboard_url
  #   assert_response :success
  # end
end
