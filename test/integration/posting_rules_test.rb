require "test_helper"

class PostingRulesTest < ActionDispatch::IntegrationTest
  test "logged in users see the posting rules above the review form" do
    log_in_as(users(:archer))
    get shop_path(shops(:one))
    assert_select ".posting-rules li", minimum: 3
    assert_select ".posting-rules a[href=?]", terms_path
  end
end
