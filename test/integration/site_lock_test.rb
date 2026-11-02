require "test_helper"

class SiteLockTest < ActionDispatch::IntegrationTest
  teardown { ENV.delete("SITE_BASIC_AUTH") }

  test "site is open when SITE_BASIC_AUTH is not set" do
    get root_path
    assert_response :success
  end

  test "site requires a password when SITE_BASIC_AUTH is set" do
    ENV["SITE_BASIC_AUTH"] = "ramen:secret"
    get root_path
    assert_response :unauthorized
    assert_equal "noindex, nofollow", response.headers["X-Robots-Tag"]

    get root_path, headers: { "Authorization" => basic("ramen", "wrong") }
    assert_response :unauthorized

    get root_path, headers: { "Authorization" => basic("ramen", "secret") }
    assert_response :success
  end

  test "health check stays reachable while locked" do
    ENV["SITE_BASIC_AUTH"] = "ramen:secret"
    get rails_health_check_path
    assert_response :success
  end

  private

    def basic(name, password)
      ActionController::HttpAuthentication::Basic.encode_credentials(name, password)
    end
end
