require "test_helper"

class ShopWebsiteTest < ActionDispatch::IntegrationTest
  def setup
    @admin = users(:michael)
    @user  = users(:archer)
    @shop  = shops(:one)
  end

  test "shop page links to the website in a new tab" do
    @shop.update!(website_url: "https://example.com/ramen")
    get shop_path(@shop)
    assert_select "a[href=?][target=_blank][rel~=noopener]", "https://example.com/ramen"
    assert_match '"sameAs":"https://example.com/ramen"', response.body
  end

  test "shop page shows no link without a website" do
    get shop_path(@shop)
    assert_select ".shop-website", count: 0
  end

  test "approved owner can set the website" do
    owner = ShopOwner.create!(user: @user, shop: @shop, status: "approved")
    log_in_as(@user)
    patch update_shop_shop_owner_path(owner), params: { shop: { website_url: "https://example.com" } }
    assert_equal "https://example.com", @shop.reload.website_url
  end

  test "admin can edit shop info and it is logged" do
    log_in_as(@admin)
    get edit_admin_shop_path(@shop)
    assert_response :success
    assert_difference "AdminAuditLog.count", 1 do
      patch admin_shop_path(@shop), params: { shop: { website_url: "https://example.com/x" } }
    end
    assert_redirected_to admin_shops_path
    assert_equal "https://example.com/x", @shop.reload.website_url
  end

  test "admin edit rejects unsafe urls" do
    log_in_as(@admin)
    patch admin_shop_path(@shop), params: { shop: { website_url: "javascript:alert(1)" } }
    assert_response :unprocessable_entity
    assert_nil @shop.reload.website_url
  end

  test "non-admins cannot edit shops through admin" do
    log_in_as(@user)
    patch admin_shop_path(@shop), params: { shop: { name: "乗っ取り" } }
    assert_redirected_to root_url
    assert_not_equal "乗っ取り", @shop.reload.name
  end

  test "approving a submission carries the website over" do
    submission = ShopSubmission.create!(user: @user, name: "新しい店", address: "東京都港区1-1",
                                        website_url: "https://new.example.com")
    log_in_as(@admin)
    patch approve_admin_shop_submission_path(submission)
    assert_equal "https://new.example.com", Shop.find_by(name: "新しい店").website_url
  end
end
