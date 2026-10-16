require "test_helper"

class ReviewReactionsControllerTest < ActionDispatch::IntegrationTest
  def setup
    @review = reviews(:one) # michael の口コミ（shop one）
    @shop = @review.shop
    @other = users(:archer)
  end

  test "other user can add and remove a helpful reaction" do
    log_in_as(@other)
    assert_difference "ReviewReaction.count", 1 do
      post shop_review_reaction_path(@shop, @review)
    end
    assert_redirected_to shop_path(@shop, anchor: "review-#{@review.id}")

    assert_no_difference "ReviewReaction.count" do
      post shop_review_reaction_path(@shop, @review)
    end

    get shop_path(@shop)
    assert_select "#review-#{@review.id} .reaction-button--on .reaction-count", text: "1"

    assert_difference "ReviewReaction.count", -1 do
      delete shop_review_reaction_path(@shop, @review)
    end
  end

  test "cannot react to own review" do
    log_in_as(users(:michael))
    assert_no_difference "ReviewReaction.count" do
      post shop_review_reaction_path(@shop, @review)
    end
    get shop_path(@shop)
    assert_select "#review-#{@review.id} .reaction-button", count: 0
  end

  test "logged out user cannot react but sees the count" do
    ReviewReaction.create!(review: @review, user: @other)
    assert_no_difference "ReviewReaction.count" do
      post shop_review_reaction_path(@shop, @review)
    end
    assert_redirected_to login_url

    get shop_path(@shop)
    assert_select "#review-#{@review.id} .reaction-summary", text: /1人が参考になった/
  end

  test "review must belong to the shop in the URL" do
    log_in_as(@other)
    assert_no_difference "ReviewReaction.count" do
      post shop_review_reaction_path(shops(:two), @review)
    end
    assert_response :not_found
  end
end
