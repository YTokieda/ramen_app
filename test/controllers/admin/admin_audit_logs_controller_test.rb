require "test_helper"

class Admin::AdminAuditLogsControllerTest < ActionDispatch::IntegrationTest
  def setup
    @admin = users(:michael)
    @normal_user = users(:archer)
  end

  test "admin should access audit logs" do
    log_in_as(@admin)

    get admin_admin_audit_logs_path

    assert_response :success
  end

  test "normal user should not access audit logs" do
    log_in_as(@normal_user)

    get admin_admin_audit_logs_path

    assert_redirected_to root_url
  end

  test "guest should not access audit logs" do
    get admin_admin_audit_logs_path

    assert_redirected_to login_url
  end
  
  test "audit logs should not have modification routes" do
    assert_raises(ActionController::UrlGenerationError) do
      Rails.application.routes.url_helpers.url_for(
        controller: "admin/admin_audit_logs",
        action: "create",
        only_path: true
      )
    end
  
    assert_raises(ActionController::UrlGenerationError) do
      Rails.application.routes.url_helpers.url_for(
        controller: "admin/admin_audit_logs",
        action: "destroy",
        id: 1,
        only_path: true
      )
    end
  end
    
  test "admin should not modify audit logs through HTTP" do
    log_in_as(@admin)
  
    assert_no_difference "AdminAuditLog.count" do
      post "/admin/admin_audit_logs",
           params: {
             admin_audit_log: {
               action_type: "approve"
             }
           }
    end
  
    assert_response :not_found
  end
  
end