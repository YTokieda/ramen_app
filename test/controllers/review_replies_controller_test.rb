require "test_helper"

class ReviewRepliesControllerTest < ActionDispatch::IntegrationTest
  
  def setup
    @user = users(:archer)
    @shop = shops(:one)
    @review = Review.create!(
      user: users(:michael),
      shop: @shop,
      content: "美味しかったです"
    )
    
  end
  
  test "approved shop owner should reply to review" do
    ShopOwner.create!(
      user: @user,
      shop: @shop,
      status: "approved"
    )
    
    log_in_as(@user)
    
     assert_difference "ReviewReply.count", 1 do
       post shop_review_review_reply_path(@shop, @review),
         params: {
           review_reply: {
             content: "ご来店ありがとうございました"
           }
         }
     end
     
     assert_redirected_to shop_path(@shop)
     reply = ReviewReply.last
     
      assert_equal "ご来店ありがとうございました",
               reply.content
  end
      
  test "pending shop owner should not reply to review" do
      ShopOwner.create!(
        user: @user,
        shop: @shop,
        status: "pending"
      )
    
      log_in_as(@user)
    
      assert_no_difference "ReviewReply.count" do
        post shop_review_review_reply_path(@shop, @review),
             params: {
               review_reply: {
                 content: "返信します"
         
              }
             }
      end
    
      assert_redirected_to shop_path(@shop)
  end
  
  
  test "normal user should not reply to review" do
    @normaluser = users(:lana)
    
    log_in_as(@normaluser)
    
    assert_no_difference "ReviewReply.count" do
      
    post shop_review_review_reply_path(@shop, @review),
      params: {
        review_reply: {
               content: "返信します"
        }
      }
    end
  end
  
  test "owner should not reply to another shops review" do
    other_shop = shops(:two)
    
    ShopOwner.create!(
      user: @user,
      shop: other_shop,
      status: "approved"
    )
    
    log_in_as(@user)
    
    assert_no_difference "ReviewReply.count" do
      post shop_review_review_reply_path(@shop,@review),
        params:{
          review_reply: {
                  content: "返信します" 
          }
        }
    end
    
    assert_redirected_to shop_path(@shop)
  end
  
  test "logged out user should not reply to review" do
    
    assert_no_difference "ReviewReply.count" do
      post shop_review_review_reply_path(@shop,@review),
        params:{
          review_reply: {
                  content: "返信します" 
          }
        }
    end
    
    assert_redirected_to login_url
    
  end
  
  test "reply content should not be blank" do
    ShopOwner.create!(
      user: @user,
      shop: @shop,
      status: "approved"
    )
    
    log_in_as(@user)
    
     assert_no_difference "ReviewReply.count" do
       post shop_review_review_reply_path(@shop, @review),
         params: {
           review_reply: {
             content: "  "
           }
         }
     end
     
     assert_redirected_to shop_path(@shop)
    
  end
  
  test "rejected shop owner should not reply to review" do
    ShopOwner.create!(
      user: @user,
      shop: @shop,
      status: "rejected"
    )
  
    log_in_as(@user)
  
    assert_no_difference "ReviewReply.count" do
      post shop_review_review_reply_path(@shop, @review),
           params: {
             review_reply: {
               content: "返信します"
             }
           }
    end
  
    assert_redirected_to shop_path(@shop)
    assert_nil @review.reload.review_reply
  end
  
  test "owner should not reply through another shop URL" do
    ShopOwner.create!(
      user: @user,
      shop: @shop,
      status: "approved"
    )
  
    other_shop = shops(:two)
  
    log_in_as(@user)
  
    assert_no_difference "ReviewReply.count" do
      post shop_review_review_reply_path(other_shop, @review),
           params: {
             review_reply: {
               content: "別店舗URLからの返信"
             }
           }
    end
  
    assert_response :not_found
    assert_nil @review.reload.review_reply
  end
  
  test "owner should not create duplicate reply" do
    shop_owner = ShopOwner.create!(
      user: @user,
      shop: @shop,
      status: "approved"
    )
  
    original_reply = ReviewReply.create!(
      review: @review,
      shop_owner: shop_owner,
      content: "最初の返信"
    )
  
    log_in_as(@user)
  
    assert_no_difference "ReviewReply.count" do
      post shop_review_review_reply_path(@shop, @review),
           params: {
             review_reply: {
               content: "2回目の返信"
             }
           }
    end
  
    assert_redirected_to shop_path(@shop)
  
    assert_equal "最初の返信",
                 original_reply.reload.content
  end
  
end
