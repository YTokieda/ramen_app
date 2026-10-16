require "test_helper"

class AdminAuditLogTest < ActiveSupport::TestCase
  def setup
    @log = AdminAuditLog.new(
      admin_user: users(:michael),
      target_type: "Verification",
      target_id: verifications(:one).id,
      action_type: "approve",
      previous_status: "pending",
      new_status: "approved"
    )
  end

  test "valid audit log should be valid" do
    assert @log.valid?
  end

  test "admin user should be required" do
    @log.admin_user = nil
    assert_not @log.valid?
  end

  test "action type should be valid" do
    @log.action_type = "publish_everything"
    assert_not @log.valid?
  end
end