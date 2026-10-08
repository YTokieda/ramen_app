require "test_helper"

class Admin::VerificationsControllerTest < ActionDispatch::IntegrationTest
  def setup
    @admin = users(:michael)
    @user = users(:archer)
    @verification = verifications(:one)
  end
  
  test "admin should get index" do
    log_in_as(@admin)
    
    get admin_verifications_path
    
    assert_response :success
  end
  
  test "admin should get show" do
    log_in_as(@admin)
    
    get admin_verification_path(@verification)
    
    assert_response :success
  end
  
  test "normal user should not get index" do
    log_in_as(@user)

    get admin_verifications_path

    assert_redirected_to root_url
  end
  
  test "admin should approve verification" do
    log_in_as(@admin)
    
    assert_equal "pending", @verification.status
    
    patch approve_admin_verification_path(@verification)
    
    @verification.reload
    
    assert_equal "approved", @verification.status
    assert_redirected_to admin_verifications_path
  end


    test "admin should reject verification" do
      log_in_as(@admin)
    
      assert_equal "pending", @verification.status
    
      patch reject_admin_verification_path(@verification)
    
      @verification.reload
    
      assert_equal "rejected", @verification.status
      assert_redirected_to admin_verifications_path
    end
    
    test "normal user should not approve verification" do
      log_in_as(@user)
    
      patch approve_admin_verification_path(@verification)
    
      @verification.reload
    
      assert_equal "pending", @verification.status
      assert_redirected_to root_url
    end
    
    test "not logged in user should not approve verification" do
      patch approve_admin_verification_path(@verification)
    
      @verification.reload
    
      assert_equal "pending", @verification.status
      assert_redirected_to login_url
    end
  
    test "not logged in user should not reject verification" do
      patch reject_admin_verification_path(@verification)
    
      @verification.reload
    
      assert_equal "pending", @verification.status
      assert_redirected_to login_url
    end
  
end