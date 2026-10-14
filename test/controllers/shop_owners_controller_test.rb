require "test_helper"

class ShopOwnersControllerTest < ActionDispatch::IntegrationTest
  
  def setup
    @user = users(:archer)
    @shop = shops(:one)
    @user2 = users(:lana)
  end
  
  test "should get new" do
    log_in_as(@user)
    get new_shop_owner_url(shop_id: @shop.id)
    assert_response :success
  end
  
  test "logged out user should not access dashboard" do
    get dashboard_shop_owners_path
    assert_redirected_to login_path
    
  end

  test "logged in user should access dashboard" do
    log_in_as(@user)
    get dashboard_shop_owners_path
    assert_response :success
  end

  test "dashboard should show only approved shop owners" do
    approved_shop_owner = ShopOwner.create!(
      user: @user,
      shop: @shop,
      status: "approved"
    )
  
    log_in_as(@user)
  
    get dashboard_shop_owners_path
  
    assert_response :success
    assert_includes assigns(:shop_owners), approved_shop_owner
  end
  
  test "dashboard should not show pending shop" do
    pending_shop = shops(:two)
  
    ShopOwner.create!(
      user: @user2,
      shop: pending_shop,
      status: "pending"
    )
  
    log_in_as(@user2)
  
    get dashboard_shop_owners_path
  
    assert_response :success
    assert_select "h2", text: pending_shop.name, count: 0
  end

  test "approved shop owner should access edit shop" do
    shop_owner = ShopOwner.create!(
      user: @user,
      shop: @shop,
      status: "approved"
    )
  
    log_in_as(@user)
  
    get edit_shop_shop_owner_path(shop_owner)
  
    assert_response :success
  end
  
  test "pending shop owner should not access edit shop" do
    shop_owner = ShopOwner.create!(
      user: @user,
      shop: @shop,
      status: "pending"
    )
    
    log_in_as(@user)
    
    get edit_shop_shop_owner_path(shop_owner)
    assert_redirected_to dashboard_shop_owners_path
  end
  
  test "user should not edit another owners shop" do
    other_user = users(:michael)
    other_shop = shops(:two)
  
    shop_owner = ShopOwner.create!(
      user: other_user,
      shop: other_shop,
      status: "approved"
    )
  
    log_in_as(@user)
  
    get edit_shop_shop_owner_path(shop_owner)
  
    assert_redirected_to dashboard_shop_owners_path
  end
  
  test "approved shop owner should update shop" do
    shop_owner = ShopOwner.create!(
      user: @user,
      shop: @shop,
      status: "approved"
    )
  
    log_in_as(@user)
  
    patch update_shop_shop_owner_path(shop_owner),
          params: {
            shop: {
              description: "店舗オーナーが更新した説明です"
            }
          }
  
    @shop.reload
  
    assert_equal "店舗オーナーが更新した説明です",
                 @shop.description
  end
  
  test "valid PDF business license should be accepted" do
    log_in_as(@user)
  
    file = Tempfile.new(["license", ".pdf"])
  
    begin
      file.binmode
      file.write("%PDF-1.4\nTest PDF")
      file.flush
  
      upload = Rack::Test::UploadedFile.new(
        file.path,
        "application/pdf",
        original_filename: "license.pdf"
      )
  
      assert_difference("ShopOwner.count", 1) do
        post shop_owners_path,
             params: {
               shop_owner: {
                 shop_id: @shop.id,
                 business_license: upload
               }
             }
      end
  
      assert_redirected_to shop_path(@shop)
  
      shop_owner = ShopOwner.order(:id).last
      assert_equal @user, shop_owner.user
      assert shop_owner.business_license.attached?
    ensure
      file.close!
    end
  end
  
  test "fake PDF business license should be rejected" do
    log_in_as(@user)
  
    file = Tempfile.new(["fake", ".pdf"])
  
    begin
      file.binmode
      file.write("This is not a PDF")
      file.flush
  
      upload = Rack::Test::UploadedFile.new(
        file.path,
        "application/pdf",
        original_filename: "fake.pdf"
      )
  
      assert_no_difference("ShopOwner.count") do
        post shop_owners_path,
             params: {
               shop_owner: {
                 shop_id: @shop.id,
                 business_license: upload
               }
             }
      end
  
      assert_response :unprocessable_entity
      assert_select "body", text: /ファイル形式が正しくありません/
    ensure
      file.close!
    end
  end
  
  test "JPEG disguised as PDF business license should be rejected" do
    log_in_as(@user)
  
    file = Tempfile.new(["fake", ".pdf"])
  
    begin
      file.binmode
      file.write("\xFF\xD8\xFF".b)
      file.flush
  
      upload = Rack::Test::UploadedFile.new(
        file.path,
        "application/pdf",
        original_filename: "fake.pdf"
      )
  
      assert_no_difference("ShopOwner.count") do
        post shop_owners_path,
             params: {
               shop_owner: {
                 shop_id: @shop.id,
                 business_license: upload
               }
             }
      end
  
      assert_response :unprocessable_entity
      assert_select "body", text: /ファイル形式が正しくありません/
    ensure
      file.close!
    end
  end
  
end

