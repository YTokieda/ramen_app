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
  
  test "PDFの営業許可証を添付できる" do
    @shop_owner.status = "pending"

    @shop_owner.business_license.attach(
      io: StringIO.new("%PDF-1.4\nTest PDF"),
      filename: "license.pdf",
      content_type: "application/pdf"
    )

    assert @shop_owner.valid?, @shop_owner.errors.full_messages.inspect
  end

  test "テキストファイルの営業許可証は拒否される" do
    @shop_owner.status = "pending"

    @shop_owner.business_license.attach(
      io: StringIO.new("This is a text file"),
      filename: "license.txt",
      content_type: "text/plain"
    )

    assert_not @shop_owner.valid?
    assert @shop_owner.errors[:business_license].any?
  end

  test "5MBを超える営業許可証は拒否される" do
    @shop_owner.status = "pending"

    @shop_owner.business_license.attach(
      io: StringIO.new("a" * (5.megabytes + 1)),
      filename: "large_license.pdf",
      content_type: "application/pdf"
    )

    assert_not @shop_owner.valid?
    assert @shop_owner.errors[:business_license].any?
  end
  
end
