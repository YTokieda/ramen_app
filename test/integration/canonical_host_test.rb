require "test_helper"

class CanonicalHostTest < ActionDispatch::IntegrationTest
  def with_canonical_host(value)
    original = ENV["CANONICAL_HOST"]
    ENV["CANONICAL_HOST"] = value
    yield
  ensure
    ENV["CANONICAL_HOST"] = original
  end

  test "no redirect when CANONICAL_HOST is not set" do
    with_canonical_host(nil) do
      get shops_path
      assert_response :success
    end
  end

  test "old host is redirected permanently to the canonical host with the same path" do
    with_canonical_host("ramen.tokworks.jp") do
      host! "ramen-app-c3yk.onrender.com"
      get "/en/shops?keyword=ramen"
      assert_response :moved_permanently
      assert_redirected_to "http://ramen.tokworks.jp/en/shops?keyword=ramen"
    end
  end

  test "canonical host is served normally" do
    with_canonical_host("ramen.tokworks.jp") do
      host! "ramen.tokworks.jp"
      get root_path
      assert_response :success
    end
  end

  test "non-GET requests are not redirected" do
    with_canonical_host("ramen.tokworks.jp") do
      host! "ramen-app-c3yk.onrender.com"
      post inquiries_path, params: { inquiry: { category: "other", name: "a", email: "a@example.com", body: "x" } }
      assert_not_equal 301, response.status
    end
  end
end
