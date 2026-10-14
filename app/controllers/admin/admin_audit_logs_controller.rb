class Admin::AdminAuditLogsController < ApplicationController
  before_action :logged_in_user
  before_action :admin_user

  def index
    @admin_audit_logs =
      AdminAuditLog
        .includes(:admin_user)
        .order(created_at: :desc, id: :desc)
        .limit(100)
  end
end