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
  
  test "fake JPEG review image should be rejected" do
    log_in_as(users(:michael))
  
    file = Tempfile.new(["fake", ".jpg"])
  
    begin
      file.binmode
      file.write("This is not a JPEG")
      file.flush
  
      upload = Rack::Test::UploadedFile.new(
        file.path,
        "image/jpeg",
        original_filename: "fake.jpg"
      )
  
      assert_no_difference("Review.count") do
        post shop_reviews_path(shops(:one)),
             params: {
               review: {
                 content: "画像付き口コミのテスト",
                 images: [upload]
               }
             }
      end
  
      assert_response :unprocessable_entity
      assert_select "body", text: /ファイル形式が正しくありません/
    ensure
      file.close!
    end
  end
  
  test "PDF disguised as JPEG review image should be rejected" do
    log_in_as(users(:michael))
  
    file = Tempfile.new(["fake", ".jpg"])
  
    begin
      file.binmode
      file.write("%PDF-1.4\nTest PDF")
      file.flush
  
      upload = Rack::Test::UploadedFile.new(
        file.path,
        "image/jpeg",
        original_filename: "fake.jpg"
      )
  
      assert_no_difference("Review.count") do
        post shop_reviews_path(shops(:one)),
             params: {
               review: {
                 content: "PDF偽装画像のテスト",
                 images: [upload]
               }
             }
      end
  
      assert_response :unprocessable_entity
      assert_select "body", text: /ファイル形式が正しくありません/
    ensure
      file.close!
    end
  end
  
  test "logged out user should not destroy review" do
    review = @user.reviews.create!(
      shop: @shop,
      content: "未ログイン削除テスト"
    )
  
    assert_no_difference("Review.count") do
      delete shop_review_path(@shop, review)
    end
  
    assert_redirected_to login_url
    assert Review.exists?(review.id)
  end
  
  test "user should not destroy own review through another shop" do
    log_in_as(@user)
  
    review = @user.reviews.create!(
      shop: @shop,
      content: "店舗の対応関係テスト"
    )
  
    other_shop = shops(:two)
  
    assert_no_difference("Review.count") do
      delete shop_review_path(other_shop, review)
    end
  
    assert_redirected_to other_shop
    assert Review.exists?(review.id)
  end
  
  
end