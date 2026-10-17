require "test_helper"

class ShopWebsiteUrlTest < ActiveSupport::TestCase
  def setup
    @shop = Shop.new(name: "URLテスト店", address: "東京都千代田区1-1")
  end

  test "website url is optional" do
    assert @shop.valid?
  end

  test "accepts http and https urls" do
    %w[https://example.com http://example.com/menu https://www.instagram.com/shop/].each do |url|
      @shop.website_url = url
      assert @shop.valid?, "#{url} should be valid"
    end
  end

  test "rejects urls that are not http or https" do
    ["javascript:alert(1)", "ftp://example.com", "example.com", "https://", "https://exa mple.com"].each do |url|
      @shop.website_url = url
      assert_not @shop.valid?, "#{url} should be invalid"
    end
  end

  test "strips spaces and stores blank as nil" do
    @shop.website_url = "  https://example.com  "
    assert_equal "https://example.com", @shop.website_url
    @shop.website_url = "   "
    assert_nil @shop.website_url
  end

  test "submission validates website url too" do
    submission = ShopSubmission.new(user: users(:michael), name: "店", address: "住所",
                                    website_url: "javascript:alert(1)")
    assert_not submission.valid?
  end
end
