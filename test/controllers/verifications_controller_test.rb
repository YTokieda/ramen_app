require "test_helper"

class VerificationsControllerTest < ActionDispatch::IntegrationTest
    
  def setup
    @user = users(:michael)
    @shop = shops(:one)
    @menu_item = menu_items(:one)
  end
  
  test "should get new" do
    log_in_as(@user)
    
    get new_shop_verification_path(
        @shop,
        menu_item_id: @menu_item.id
        )
    
    assert_response :success
 
  end
  
  test "logged in user should create verification" do
      log_in_as(@user)
      
      assert_difference "Verification.count",1 do
      
          post shop_verifications_path(@shop),
                        params: {
           menu_item_id: @menu_item.id,
           verification: {
             category: "noodle_soup",
             egg_status: "egg_free",
             source_type: "manufacturer",
             verification_method: "メーカー成分表",
             verified_on: Date.current,
             note: "メーカー公開資料を確認"
           }
         }
              
       end
      
  end
  
  test "not logged in user should not create verification" do
      assert_no_difference "Verification.count" do
      
          post shop_verifications_path(@shop),
                            params: {
               menu_item_id: @menu_item.id,
               verification: {
                 category: "noodle_soup",
                 egg_status: "egg_free",
                 source_type: "manufacturer",
                 verification_method: "メーカー成分表",
                 verified_on: Date.current,
                 note: "メーカー公開資料を確認"
               }
             }
        
      end
      
      assert_redirected_to login_url
    end


    test "should not use menu item from another shop" do
      log_in_as(@user)
    
      other_menu_item = menu_items(:two)
    
      assert_no_difference "Verification.count" do
        assert_raises ActiveRecord::RecordNotFound do
          post shop_verifications_path(@shop),
               params: {
                 menu_item_id: other_menu_item.id,
                 verification: {
                   category: "noodle_soup",
                   egg_status: "egg_free",
                   source_type: "manufacturer",
                   verification_method: "メーカー成分表",
                   verified_on: Date.current
                 }
               }
        end
      end
    end
        
    test "normal user should not set verification status to approved" do
      log_in_as(@user)

      assert_difference "Verification.count", 1 do
        post shop_verifications_path(@shop),
             params: {
               menu_item_id: @menu_item.id,
               verification: {
                 category: "noodle_soup",
                 egg_status: "egg_free",
                 source_type: "manufacturer",
                 verification_method: "メーカー成分表",
                 verified_on: Date.current,
                 status: "approved"
               }
             }
      end
    
      verification = Verification.order(:created_at).last
    
      assert_equal "pending", verification.status
            
    end
    
    test "logged in user should create cooking environment verification" do
      log_in_as(@user)
    
      assert_difference "Verification.count", 1 do
        post shop_verifications_path(@shop),
             params: {
               verification: {
                 category: "cooking_environment",
                 egg_status: "unknown",
                 source_type: "user_report",
                 verification_method: "店舗で確認",
                 verified_on: Date.current,
                 note: "共通の調理器具を使用"
               }
             }
      end
    
      verification = Verification.order(:created_at).last
    
      assert_equal @shop, verification.shop
      assert_nil verification.menu_item
      assert_equal "cooking_environment",
                   verification.category
      assert_equal "pending", verification.status
    
      assert_redirected_to @shop
    end
    
    test "show should not display history link when no history exists" do
      shop = Shop.create!(
        name: "HISTORY_NO_HISTORY_SHOP",
        address: "東京都品川区テスト1-1-1"
      )
    
      menu_item = shop.menu_items.create!(
        name: "テストラーメン"
      )
    
      Verification.create!(
        shop: shop,
        menu_item: menu_item,
        user: users(:michael),
        category: "noodle_soup",
        egg_status: "egg_free",
        source_type: "manufacturer",
        verification_method: "SINGLE_VERIFICATION_TEST",
        verified_on: Date.new(2026, 9, 15),
        status: "approved"
      )
    
      get shop_path(shop)
    
      assert_response :success
    
      assert_select "body", text: /SINGLE_VERIFICATION_TEST/
      assert_select "details", count: 0
    end
    
end