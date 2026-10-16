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
    
    
    test "approved verification should not be rejected" do
      log_in_as(@admin)
    
      @verification.update!(status: "approved")
    
      patch reject_admin_verification_path(@verification)
    
      assert_equal "approved", @verification.reload.status
      assert_redirected_to admin_verifications_path
    end
    
    test "rejected verification should not be approved" do
      log_in_as(@admin)
    
      @verification.update!(status: "rejected")
    
      patch approve_admin_verification_path(@verification)
    
      assert_equal "rejected", @verification.reload.status
      assert_redirected_to admin_verifications_path
    end
    
    test "normal user should not reject verification" do
      log_in_as(@user)
    
      patch reject_admin_verification_path(@verification)
    
      assert_equal "pending", @verification.reload.status
      assert_redirected_to root_url
    end
    
  test "admin should not approve nonexistent verification" do
    log_in_as(@admin)
  
    nonexistent_id = Verification.maximum(:id).to_i + 1
  
    assert_no_difference 'Verification.where(status: "approved").count' do
      patch approve_admin_verification_path(nonexistent_id)
    end
  
    assert_response :not_found
  end
    
    test "approved verification should not be approved again" do
      log_in_as(@admin)
    
      @verification.update!(status: "approved")
    
      patch approve_admin_verification_path(@verification)
    
      assert_equal "approved", @verification.reload.status
      assert_redirected_to admin_verifications_path
      assert_equal "この卵情報はすでに処理されています", flash[:danger]
    end
        
    test "approving verification should create audit log" do
      log_in_as(@admin)
    
      assert_difference "AdminAuditLog.count", 1 do
        patch approve_admin_verification_path(@verification)
      end
    
      log = AdminAuditLog.last
    
      assert_equal @admin, log.admin_user
      assert_equal "Verification", log.target_type
      assert_equal @verification.id, log.target_id
      assert_equal "approve", log.action_type
      assert_equal "pending", log.previous_status
      assert_equal "approved", log.new_status
    end
    
    test "rejecting verification should create audit log" do
      log_in_as(@admin)
    
      assert_difference "AdminAuditLog.count", 1 do
        patch reject_admin_verification_path(@verification)
      end
    
      log = AdminAuditLog.last
    
      assert_equal @admin, log.admin_user
      assert_equal "Verification", log.target_type
      assert_equal @verification.id, log.target_id
      assert_equal "reject", log.action_type
      assert_equal "pending", log.previous_status
      assert_equal "rejected", log.new_status
    end
        
   test "approval should rollback when audit log creation fails" do
    log_in_as(@admin)
  
    AdminAuditLog.stub(:create!, ->(*) {
      raise ActiveRecord::RecordInvalid
    }) do
  
      assert_no_difference "AdminAuditLog.count" do
        patch approve_admin_verification_path(@verification)
      end
  
      assert_response :unprocessable_entity
    end
  
    assert_equal "pending", @verification.reload.status
  end
    
end