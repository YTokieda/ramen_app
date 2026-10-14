require "test_helper"

class ReviewTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end
  
  test "JPEG画像を添付できる" do
    review = reviews(:one)
  
    review.images.attach(
      io: StringIO.new("Test image"),
      filename: "ramen.jpg",
      content_type: "image/jpeg"
    )
  
    assert review.valid?, review.errors.full_messages.inspect
  end
  
  test "テキストファイルは口コミ画像として添付できない" do
    review = reviews(:one)
  
    review.images.attach(
      io: StringIO.new("Invalid image"),
      filename: "ramen.txt",
      content_type: "text/plain"
    )
  
    assert_not review.valid?
    assert review.errors[:images].any?
  end
  
  test "5MBを超える口コミ画像は拒否される" do
    review = reviews(:one)
  
    review.images.attach(
      io: StringIO.new("a" * (5.megabytes + 1)),
      filename: "large.jpg",
      content_type: "image/jpeg"
    )
  
    assert_not review.valid?
    assert review.errors[:images].any?
  end
  
  test "口コミ画像は4枚以上添付できない" do
    review = reviews(:one)
  
    4.times do |i|
      review.images.attach(
        io: StringIO.new("Test image #{i}"),
        filename: "ramen_#{i}.jpg",
        content_type: "image/jpeg"
      )
    end
  
    assert_not review.valid?
    assert review.errors[:images].any?
  end
  
  
  
  
  
end
