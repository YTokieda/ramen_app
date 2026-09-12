require "test_helper"

class ReviewsControllerTest < ActionDispatch::IntegrationTest

  def setup
    @user = users(:michael)
    @shop = shops(:one)
  end

  test "logged in user should create review" do
    log_in_as(@user)

    assert_difference "Review.count", 1 do
      post shop_reviews_path(@shop),
           params: {
             review: {
               content: "おいしいラーメンでした"
             }
           }
    end

    assert_redirected_to @shop
  end
  
  test "logged out user should not create review" do
   assert_no_difference "Review.count" do
     post shop_reviews_path(@shop),
          params: {
            review: {
              content: "未ログインからの投稿"
            }
          }
  end

    assert_redirected_to login_url
  end
  
  test "user should destroy own review" do
      log_in_as(@user)
      
      review = @user.reviews.create!(
          shop: @shop,
          content: "削除テスト口コミ"
      )
      
      assert_difference "Review.count", -1 do
          delete shop_review_path(@shop, review)
      end
      
      assert_redirected_to @shop
  end
  
  test "user should not destroy another user's review" do
     other_user = users(:archer)
     review = other_user.reviews.create!(
        shop: @shop,
        content: "他人の口コミです"
        )
     
     log_in_as(@user)
     
     assert_no_difference "Review.count" do
        delete shop_review_path(@shop,review)
     end
     
     assert_redirected_to @shop
      
  end
  
  
end