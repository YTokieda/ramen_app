require "test_helper"

class Admin::InquiriesControllerTest < ActionDispatch::IntegrationTest
  def setup
    @admin = users(:michael)
    @user = users(:archer)
    @inquiry = inquiries(:wrong_info)
  end

  test "admin can list and view inquiries" do
    log_in_as(@admin)
    get admin_inquiries_path
    assert_response :success
    assert_select "a[href=?]", admin_inquiry_path(@inquiry)

    get admin_inquiry_path(@inquiry)
    assert_response :success
    assert_match @inquiry.body, response.body
  end

  test "normal user and guest cannot see inquiries" do
    get admin_inquiries_path
    assert_redirected_to login_url

    log_in_as(@user)
    get admin_inquiry_path(@inquiry)
    assert_redirected_to root_url
  end

  test "admin can update status and it is audited" do
    log_in_as(@admin)
    assert_difference "AdminAuditLog.count", 1 do
      patch admin_inquiry_path(@inquiry), params: { inquiry: { status: "closed" } }
    end
    assert_equal "closed", @inquiry.reload.status
    log = AdminAuditLog.last
    assert_equal ["Inquiry", "new", "closed"], [log.target_type, log.previous_status, log.new_status]
  end

  test "invalid status is rejected" do
    log_in_as(@admin)
    assert_no_difference "AdminAuditLog.count" do
      patch admin_inquiry_path(@inquiry), params: { inquiry: { status: "deleted" } }
    end
    assert_equal "new", @inquiry.reload.status
  end

  test "normal user cannot update status" do
    log_in_as(@user)
    patch admin_inquiry_path(@inquiry), params: { inquiry: { status: "closed" } }
    assert_equal "new", @inquiry.reload.status
  end
end
