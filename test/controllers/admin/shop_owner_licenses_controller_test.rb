
require "test_helper"

class Admin::ShopOwnerLicensesControllerTest < ActionDispatch::IntegrationTest
  setup do
    @shop_owner = shop_owners(:one)

    @shop_owner.business_license.attach(
      io: StringIO.new("sample license"),
      filename: "license.pdf",
      content_type: "application/pdf"
    )

    @url = admin_shop_owner_business_license_path(@shop_owner)
  end

  test "admin can download business license" do
    log_in_as(users(:michael))

    get @url

    assert_response :success
    assert_equal "sample license", response.body
  end

  test "normal user cannot download business license" do
    log_in_as(users(:archer))

    get @url

    assert_redirected_to root_url
  end

  test "guest cannot download business license" do
    get @url

    assert_redirected_to login_url
  end
  
  test "admin cannot download missing business license" do
    log_in_as(users(:michael))
  
    @shop_owner.business_license.purge
  
    assert_raises(ActiveRecord::RecordNotFound) do
      get @url
    end
  end
  
  test "business license download has security headers" do
    log_in_as(users(:michael))
  
    get @url
  
    assert_response :success
  
    assert_equal "private, no-store",
                 response.headers["Cache-Control"]
  
    assert_equal "nosniff",
                 response.headers["X-Content-Type-Options"]
  
    assert_equal "application/octet-stream",
                 response.media_type
  
    assert_match(
      /attachment/,
      response.headers["Content-Disposition"]
    )
  end
  
  
end
