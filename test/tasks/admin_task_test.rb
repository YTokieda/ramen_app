require "test_helper"
require "rake"

class AdminTaskTest < ActiveSupport::TestCase
  setup do
    Rails.application.load_tasks if Rake::Task.tasks.empty?
    @task = Rake::Task["admin:grant_from_env"]
  end

  teardown do
    ENV.delete("ADMIN_EMAILS")
  end

  def run_task
    @task.reenable
    capture_io { @task.invoke }
  end

  test "grants admin to activated users listed in ADMIN_EMAILS" do
    user = users(:archer)
    assert_not user.admin?
    ENV["ADMIN_EMAILS"] = " #{user.email.upcase} , unknown@example.com"
    run_task
    assert user.reload.admin?
  end

  test "does nothing for inactive users or when unset" do
    user = users(:lana)
    user.update_columns(activated: false)
    ENV["ADMIN_EMAILS"] = user.email
    run_task
    assert_not user.reload.admin?

    ENV.delete("ADMIN_EMAILS")
    run_task
    assert_not users(:archer).reload.admin?
  end
end
