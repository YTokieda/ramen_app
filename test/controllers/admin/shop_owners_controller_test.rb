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
  
  test "normal user should not approve shop owner" do
    log_in_as(@user)
  
    patch approve_admin_shop_owner_path(@shop_owner)
  
    assert_equal "pending", @shop_owner.reload.status
    assert_redirected_to root_url
  end
  
  test "normal user should not reject shop owner" do
    log_in_as(@user)
  
    patch reject_admin_shop_owner_path(@shop_owner)
  
    assert_equal "pending", @shop_owner.reload.status
    assert_redirected_to root_url
  end
  
  test "logged out user should not approve shop owner" do
    patch approve_admin_shop_owner_path(@shop_owner)
  
    assert_equal "pending", @shop_owner.reload.status
    assert_redirected_to login_url
  end

  test "rejected shop owner should not be approved" do
    log_in_as(@admin)
  
    @shop_owner.update!(status: "rejected")
  
    patch approve_admin_shop_owner_path(@shop_owner)
  
    assert_equal "rejected", @shop_owner.reload.status
    assert_redirected_to admin_shop_owners_path
    assert_equal "この申請はすでに処理されています", flash[:danger]
  end
  
  test "approving shop owner should create audit log" do
    log_in_as(@admin)
  
    assert_difference "AdminAuditLog.count", 1 do
      patch approve_admin_shop_owner_path(@shop_owner)
    end
  
    log = AdminAuditLog.last
  
    assert_equal @admin, log.admin_user
    assert_equal "ShopOwner", log.target_type
    assert_equal @shop_owner.id, log.target_id
    assert_equal "approve", log.action_type
    assert_equal "pending", log.previous_status
    assert_equal "approved", log.new_status
  
    assert_equal "approved", @shop_owner.reload.status
  end
  
  
  test "rejecting shop owner should create audit log" do
    log_in_as(@admin)
  
    assert_difference "AdminAuditLog.count", 1 do
      patch reject_admin_shop_owner_path(@shop_owner)
    end
  
    log = AdminAuditLog.last
  
    assert_equal @admin, log.admin_user
    assert_equal "ShopOwner", log.target_type
    assert_equal @shop_owner.id, log.target_id
    assert_equal "reject", log.action_type
    assert_equal "pending", log.previous_status
    assert_equal "rejected", log.new_status
  
    assert_equal "rejected", @shop_owner.reload.status
  end
  
  
  test "shop owner approval should rollback when audit log fails" do
    log_in_as(@admin)
  
    AdminAuditLog.stub(:create!, ->(*) {
      raise ActiveRecord::RecordInvalid
    }) do
  
      assert_no_difference "AdminAuditLog.count" do
        assert_raises(ActiveRecord::RecordInvalid) do
          patch approve_admin_shop_owner_path(@shop_owner)
        end
      end
  
    end
  
    assert_equal "pending", @shop_owner.reload.status
  end

end