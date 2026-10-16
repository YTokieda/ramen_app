
require "test_helper"

class ReviewImagesControllerTest < ActionDispatch::IntegrationTest
  setup do
     
    @review = reviews(:one)

    @review.images.attach(
      io: StringIO.new("sample image"),
      filename: "sample.png",
      content_type: "image/png"
    )

    @attachment = @review.images.first
  end

  test "guest can download review image" do
    get review_image_path(@review, @attachment)

    assert_response :success
    assert_equal "sample image", response.body
  end

  test "cannot download image from another review" do
    other_review = reviews(:two)
  
    get review_image_path(other_review, @attachment)
  
    assert_response :not_found
  end
end
