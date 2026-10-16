require "test_helper"

class Admin::ShopSubmissionsControllerTest < ActionDispatch::IntegrationTest

  def setup
    @admin = users(:michael)
    @user = users(:archer)
    @submission = shop_submissions(:one)
  end

  test "admin should get index" do
    log_in_as(@admin)

    get admin_shop_submissions_path

    assert_response :success
  end

  test "normal user should not get index" do
    log_in_as(@user)

    get admin_shop_submissions_path

    assert_redirected_to root_url
  end

  test "normal user should not approve submission" do
    log_in_as(@user)

    patch approve_admin_shop_submission_path(@submission)

    assert_equal "pending", @submission.reload.status
    assert_redirected_to root_url
  end

  test "admin should reject submission" do
    log_in_as(@admin)

    patch reject_admin_shop_submission_path(@submission)

    assert_equal "rejected", @submission.reload.status
    assert_redirected_to admin_shop_submissions_path
  end

  test "approved submission should not be rejected" do
    log_in_as(@admin)

    @submission.update!(status: "approved")

    patch reject_admin_shop_submission_path(@submission)

    assert_equal "approved", @submission.reload.status
    assert_redirected_to admin_shop_submissions_path
  end

  test "rejected submission should not be approved" do
    log_in_as(@admin)

    @submission.update!(status: "rejected")

    patch approve_admin_shop_submission_path(@submission)

    assert_equal "rejected", @submission.reload.status
    assert_redirected_to admin_shop_submissions_path
  end

 test "normal user should not reject submission" do
    log_in_as(@user)
  
    patch reject_admin_shop_submission_path(@submission)
  
    assert_equal "pending", @submission.reload.status
    assert_redirected_to root_url
  end
  
  test "logged out user should not approve submission" do
    assert_no_difference "Shop.count" do
      patch approve_admin_shop_submission_path(@submission)
    end
  
    assert_equal "pending", @submission.reload.status
    assert_redirected_to login_url
  end
  
  test "admin should not approve nonexistent submission" do
    log_in_as(@admin)
  
    nonexistent_id = ShopSubmission.maximum(:id).to_i + 1
  
    assert_no_difference "Shop.count" do
      patch approve_admin_shop_submission_path(nonexistent_id)
    end
  
    assert_response :not_found
  end

  test "approving same submission twice should create only one shop" do
    log_in_as(@admin)
  
    assert_difference "Shop.count", 1 do
      patch approve_admin_shop_submission_path(@submission)
    end
  
    assert_equal "approved", @submission.reload.status
  
    assert_no_difference "Shop.count" do
      patch approve_admin_shop_submission_path(@submission)
    end
  
    assert_equal "approved", @submission.reload.status
    assert_redirected_to admin_shop_submissions_path
  end

  test "admin should not approve submission for existing shop" do
    log_in_as(@admin)
  
    Shop.find_or_create_by!(
      name: @submission.name,
      address: @submission.address
    )
  
    assert_no_difference "Shop.count" do
      patch approve_admin_shop_submission_path(@submission)
    end
  
    assert_equal "pending", @submission.reload.status
    assert_redirected_to admin_shop_submission_path(@submission)
  end

  test "rejecting same submission twice should keep rejected status" do
    log_in_as(@admin)
  
    patch reject_admin_shop_submission_path(@submission)
  
    assert_equal "rejected", @submission.reload.status
    assert_redirected_to admin_shop_submissions_path
  
    patch reject_admin_shop_submission_path(@submission)
  
    assert_equal "rejected", @submission.reload.status
    assert_redirected_to admin_shop_submissions_path
  end

  test "rejected submission should not create shop when approved" do
    log_in_as(@admin)
  
    @submission.update!(status: "rejected")
  
    assert_no_difference "Shop.count" do
      patch approve_admin_shop_submission_path(@submission)
    end
  
    assert_equal "rejected", @submission.reload.status
    assert_redirected_to admin_shop_submissions_path
  end

  test "approving shop submission should create audit log" do
    log_in_as(@admin)
  
    assert_difference "AdminAuditLog.count", 1 do
      assert_difference "Shop.count", 1 do
        patch approve_admin_shop_submission_path(@submission)
      end
    end
  
    log = AdminAuditLog.last
  
    assert_equal @admin, log.admin_user
    assert_equal "ShopSubmission", log.target_type
    assert_equal @submission.id, log.target_id
    assert_equal "approve", log.action_type
    assert_equal "pending", log.previous_status
    assert_equal "approved", log.new_status
  
    assert_equal "approved", @submission.reload.status
    assert_redirected_to admin_shop_submissions_path
  end

  test "rejecting shop submission should create audit log" do
    log_in_as(@admin)
  
    assert_difference "AdminAuditLog.count", 1 do
      patch reject_admin_shop_submission_path(@submission)
    end
  
    log = AdminAuditLog.last
  
    assert_equal @admin, log.admin_user
    assert_equal "ShopSubmission", log.target_type
    assert_equal @submission.id, log.target_id
    assert_equal "reject", log.action_type
    assert_equal "pending", log.previous_status
    assert_equal "rejected", log.new_status
  
    assert_equal "rejected", @submission.reload.status
    assert_redirected_to admin_shop_submissions_path
  end

  test "processed submission should not create another audit log" do
    log_in_as(@admin)
  
    @submission.update!(status: "approved")
  
    assert_no_difference "AdminAuditLog.count" do
      patch approve_admin_shop_submission_path(@submission)
    end
  
    assert_equal "approved", @submission.reload.status
    assert_redirected_to admin_shop_submissions_path
  end
  
  test "shop submission approval should rollback when audit log fails" do
    log_in_as(@admin)
  
    AdminAuditLog.stub(:create!, ->(*) {
      raise ActiveRecord::RecordInvalid
    }) do
  
      assert_no_difference "Shop.count" do
        assert_no_difference "AdminAuditLog.count" do
          patch approve_admin_shop_submission_path(@submission)
        end
      end
  
    end
  
    assert_equal "pending", @submission.reload.status
  end

end