require "test_helper"

class AdminModerationTest < ActionDispatch::IntegrationTest
  def setup
    @admin = users(:michael)
    @user  = users(:archer)
    @shop  = shops(:one)
  end

  test "non-admins cannot moderate" do
    log_in_as(@user)
    patch hide_admin_shop_path(@shop)
    assert_redirected_to root_url
    assert_not @shop.reload.hidden?

    assert_no_difference "Review.count" do
      delete admin_review_path(reviews(:one))
    end
    assert_no_difference "MenuItem.count" do
      delete admin_menu_item_path(menu_items(:one))
    end
    get admin_reviews_path
    assert_redirected_to root_url
  end

  test "hidden shop disappears for the public and comes back when unhidden" do
    log_in_as(@admin)
    assert_difference "AdminAuditLog.count", 1 do
      patch hide_admin_shop_path(@shop)
    end
    assert @shop.reload.hidden?

    get shop_path(@shop)
    assert_response :success
    assert_select ".alert-warning", text: /非公開/

    delete logout_path
    get shop_path(@shop)
    assert_response :not_found
    get shops_path
    assert_no_match @shop.name, response.body

    log_in_as(@user)
    assert_no_difference "Review.count" do
      post shop_reviews_path(@shop), params: { review: { content: "非公開の店舗へ" } }
    end
    assert_response :not_found

    delete logout_path
    log_in_as(@admin)
    patch unhide_admin_shop_path(@shop)
    assert_not @shop.reload.hidden?
    delete logout_path
    get shop_path(@shop)
    assert_response :success
  end

  test "admin can delete a review and a menu item with an audit log" do
    log_in_as(@admin)
    get admin_reviews_path
    assert_response :success

    review = reviews(:two)
    assert_difference ["Review.count", "-AdminAuditLog.count"], -1 do
      delete admin_review_path(review)
    end

    menu_item = menu_items(:one)
    assert_difference "MenuItem.count", -1 do
      delete admin_menu_item_path(menu_item)
    end
    assert_redirected_to shop_path(menu_item.shop)
    assert_equal "delete", AdminAuditLog.last.action_type
  end
end
