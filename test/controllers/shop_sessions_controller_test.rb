require "test_helper"

class ShopSessionsControllerTest < ActionDispatch::IntegrationTest
  test "should get new" do
    get shop_owner_login_url
    assert_response :success
  end
end
