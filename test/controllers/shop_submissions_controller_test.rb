require "test_helper"

class ShopSubmissionsControllerTest < ActionDispatch::IntegrationTest

  def setup
     @admin = users(:michael)
     @user = users(:archer)
      
     @shop_submission = ShopSubmission.create!(
        user: @user,
        name: "テストラーメン店",
        address: "東京都品川区1-1-1",
        description: "テスト用店舗情報",
        status: "pending"
      )
  end
  
  test "non admin user should not access admin shop submissions" do
    log_in_as(@user)
    get admin_shop_submissions_path
    assert_redirected_to root_url
  end
  
  test "admin should approve shop submission" do
    log_in_as(@admin)
    assert_difference "Shop.count", 1 do
      patch approve_admin_shop_submission_path(@shop_submission)
    end
    @shop_submission.reload
    
    assert_equal "approved", @shop_submission.status
    assert_redirected_to admin_shop_submissions_path
  end
  
  test "admin should reject shop submission" do
    log_in_as(@admin)
    assert_no_difference "Shop.count" do
      patch reject_admin_shop_submission_path(@shop_submission)
    end
    @shop_submission.reload
    
    assert_equal "rejected", @shop_submission.status
    assert_redirected_to admin_shop_submissions_path
  end
  
  test "approved submission should not be approved twice" do
    log_in_as(@admin)

    patch approve_admin_shop_submission_path(@shop_submission)

    assert_no_difference "Shop.count" do
      patch approve_admin_shop_submission_path(@shop_submission)
    end
  end
  
  test "admin should not approve duplicate shop" do
    log_in_as(@admin)
  
    Shop.create!(
      name: @shop_submission.name,
      address: @shop_submission.address
    )
  
    assert_no_difference "Shop.count" do
      patch approve_admin_shop_submission_path(@shop_submission)
    end
  
    @shop_submission.reload
  
    assert_equal "pending", @shop_submission.status
    assert_redirected_to admin_shop_submission_path(@shop_submission)
  end
  
  
end
