require "test_helper"

class ShopOwnerTest < ActiveSupport::TestCase
  include ActionDispatch::TestProcess
  
  def setup
    @user = User.create!(name:"山田",email:"owner@example.com",password:"password",password_confirmation: "password")
    @shop = Shop.create!(name: "テストラーメン", address: "東京都渋谷区1-2-3")
    @shop_owner = ShopOwner.new(
      user: @user,
      shop: @shop
    )
  end

  test "有効なオーナーは保存できる" do
    assert @shop_owner.valid?
  end

  test "shop削除でshop_ownerも削除される" do
    @shop_owner.save!
    assert_difference("ShopOwner.count", -1) do
      @shop.destroy
    end
  end
end
