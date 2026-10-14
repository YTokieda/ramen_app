require "test_helper"

class VerificationTest < ActiveSupport::TestCase
  def setup
    @user = users(:michael)
    @shop = shops(:one)

    @menu_item = MenuItem.create!(
      shop: @shop,
      name: "醤油ラーメン"
    )

    @verification = Verification.new(
      user: @user,
      shop: @shop,
      menu_item: @menu_item,
      category: "noodle_soup",
      egg_status: "egg_free",
      source_type: "manufacturer",
      verification_method: "メーカー成分表",
      verified_on: Date.current,
      note: "成分表を確認"
    )
  end
  
  test "should be valid" do
    assert @verification.valid?
  end
  
  test "shop should be present" do
    @verification.shop = nil
    
    assert_not @verification.valid?
  end
  
  test "user should be present" do
    @verification.user = nil
  
    assert_not @verification.valid?
  end
  
  test "menu item may be nil" do
    @verification.menu_item = nil
    @verification.category = "cooking_environment"

    assert @verification.valid?
  end

  test "noodle_soup verification should require menu item" do
    @verification.category = "noodle_soup"
    @verification.menu_item = nil

    assert_not @verification.valid?
  end
  

  test "topping verification should require menu item" do
    @verification.category = "topping"
    @verification.menu_item = nil

    assert_not @verification.valid?
  end
  
  
  test "cooking environment should not have menu item" do
    @verification.category = "cooking_environment"
    @verification.menu_item = @menu_item
  
    assert_not @verification.valid?
  end
  
  test "cooking environment without menu item should be valid" do
    @verification.category = "cooking_environment"
    @verification.menu_item = nil
  
    assert @verification.valid?
  end

  test "menu item should belong to same shop" do
    other_shop = shops(:two)
  
    other_menu_item = MenuItem.create!(
      shop: other_shop,
      name: "塩ラーメン"
    )
  
    @verification.menu_item = other_menu_item
  
    assert_not @verification.valid?
  end
  
  test "category should be present" do
    @verification.category = nil
  
    assert_not @verification.valid?
  end
  
  test "category should be valid value" do
    @verification.category = "ramen"
  
    assert_not @verification.valid?
  end
  
  test "egg status should be present" do
    @verification.egg_status = nil
  
    assert_not @verification.valid?
  end

  test "egg status should be valid value" do
    @verification.egg_status = "safe"
  
    assert_not @verification.valid?
  end
  
  test "source type should be present" do
    @verification.source_type = nil
  
    assert_not @verification.valid?
  end

  test "source type should be valid value" do
    @verification.source_type = "internet"
  
    assert_not @verification.valid?
  end
  
  test "verified on should be present" do
    @verification.verified_on = nil
  
    assert_not @verification.valid?
  end
    
  test "status should default to pending" do
    @verification = Verification.new
    
    assert_equal "pending", @verification.status
  end  
  
  test "status should reject invalid value" do
    @verification.status = "confirmed"
  
    assert_not @verification.valid?
  end
  
  test "approved status should be valid" do
    @verification.status = "approved"
  
    assert @verification.valid?
  end
    
    
    
  test "PDFの証拠資料を添付できる" do
    verification = verifications(:one)
  
    verification.evidence_files.attach(
      io: StringIO.new("%PDF-1.4\nTest PDF"),
      filename: "evidence.pdf",
      content_type: "application/pdf"
    )
  
    assert verification.valid?, verification.errors.full_messages.inspect
  end
  
  test "許可されていない証拠資料は拒否される" do
    verification = verifications(:one)
  
    verification.evidence_files.attach(
      io: StringIO.new("Invalid file"),
      filename: "evidence.txt",
      content_type: "text/plain"
    )
  
    assert_not verification.valid?
    assert verification.errors[:evidence_files].any?
  end
  
  test "5MBを超える証拠資料は拒否される" do
    verification = verifications(:one)
  
    verification.evidence_files.attach(
      io: StringIO.new("a" * (5.megabytes + 1)),
      filename: "large.pdf",
      content_type: "application/pdf"
    )
  
    assert_not verification.valid?
    assert verification.errors[:evidence_files].any?
  end
  
  test "証拠資料は4ファイル以上添付できない" do
    verification = verifications(:one)
  
    4.times do |i|
      verification.evidence_files.attach(
        io: StringIO.new("Test PDF #{i}"),
        filename: "evidence_#{i}.pdf",
        content_type: "application/pdf"
      )
    end
  
    assert_not verification.valid?
    assert verification.errors[:evidence_files].any?
  end  
    
    
end
