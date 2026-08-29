require "test_helper"

class ShopOwnerTest < ActiveSupport::TestCase
  include ActionDispatch::TestProcess
  
  def setup
    @shop = Shop.create!(name: "テストラーメン", address: "東京都渋谷区1-2-3")
    @shop_owner = ShopOwner.new(
      name: "山田太郎",
      email: "owner@example.com",
      password: "password",
      password_confirmation: "password",
      business_license: fixture_file_upload("kitten.jpg", "image/jpeg"),
      shop: @shop
    )
  end

  test "有効なオーナーは保存できる" do
    assert @shop_owner.valid?
  end

  test "メールがなければ無効" do
    @shop_owner.email = ""
    assert_not @shop_owner.valid?
  end

  test "同一メールは登録できない" do
    @shop_owner.save!
    duplicate = @shop_owner.dup
    assert_not duplicate.valid?
  end

  test "shop削除でshop_ownerも削除される" do
    @shop_owner.save!
    assert_difference("ShopOwner.count", -1) do
      @shop.destroy
    end
  end
end
