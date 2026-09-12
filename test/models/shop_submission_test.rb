require "test_helper"

class ShopSubmissionTest < ActiveSupport::TestCase
  def setup
      @user = users(:michael)
      
      @shop_submission = ShopSubmission.new(
        user: @user,
        name: "テストラーメン店",
        address: "東京都品川区1-1-1",
        description: "テスト店舗です"
        )
  end
  
  test "should be valid" do
    assert @shop_submission.valid?
  end
  
  test "name should be present" do
    @shop_submission.name ="　"
    assert_not @shop_submission.valid?
  end
  
  test "address should be present" do
    @shop_submission.address = "   "
    assert_not @shop_submission.valid?
  end
  
  test "status should default to pending" do
    assert_equal "pending", @shop_submission.status
  end
  
  test "status should accept valid values" do
    %w[pending approved rejected].each do |status|
      @shop_submission.status = status
      assert @shop_submission.valid?
    end
  end
  
  test "status should reject invalid value" do
    @shop_submission.status = "done"
    assert_not @shop_submission.valid?
    
  end
  
end
