require "test_helper"

class UsersProfileTest < ActionDispatch::IntegrationTest
  include ApplicationHelper

  def setup
    @user  = users(:michael)
    @other = users(:archer)
  end

  test "profile display" do
    get user_path(@user)
    assert_template 'users/show'
    assert_select 'title', full_title(@user.name)
  end

  test "public profile shows reviews but not private submissions" do
    get user_path(@user)
    assert_select 'h1', text: "#{@user.name}さんのページ"
    assert_match reviews(:one).content, response.body
    assert_match shops(:one).name, response.body
    assert_no_match shop_submissions(:one).name, response.body
    assert_no_match @user.email, response.body
    assert_select 'a[href=?]', edit_user_path(@user), count: 0
  end

  test "own page shows submission status" do
    log_in_as(@user)
    get user_path(@user)
    assert_select 'h1', text: "マイページ"
    assert_match shop_submissions(:one).name, response.body
    assert_select 'span.status-chip--pending'
    assert_select 'a[href=?]', edit_user_path(@user)
  end

  test "other user's private data stays hidden after login" do
    log_in_as(@other)
    get user_path(@user)
    assert_no_match shop_submissions(:one).name, response.body
  end

  test "inactive user page redirects" do
    inactive = users(:malory)
    inactive.update_columns(activated: false, activated_at: nil)
    get user_path(inactive)
    assert_redirected_to root_url
  end
end
