require "test_helper"

class UsersEditTest < ActionDispatch::IntegrationTest
  
  def setup
    @user = users(:michael) 
  end
  
  test "unsuccessful edit" do
    log_in_as(@user)
    get edit_user_path(@user)
    assert_template 'users/edit'
    patch user_path(@user), params: { user: { name:  "",
                                              email: "foo@invalid",
                                              password:              "foo",
                                              password_confirmation: "bar" } }
    assert_template 'users/edit'
  end

  test "successful edit with friendly forwarding" do
    get edit_user_path(@user)
    log_in_as(@user)
    assert_redirected_to edit_user_path(@user)
    get edit_user_path(@user)
    assert_template 'users/edit'
    name  = "Foo Bar"
    email = "foo@bar.com"
    patch user_path(@user), params: { user: { name:  name,
                                              email: email,
                                              current_password: "password",
                                              password:              "",
                                              password_confirmation: "" } }
    assert_not flash.empty?
    assert_redirected_to @user
    @user.reload
    assert_equal name,  @user.name
    assert_equal email, @user.email
  end

  test "changing email or password needs the current password" do
    log_in_as(@user)
    patch user_path(@user), params: { user: { name: @user.name, email: "new@bar.com" } }
    assert_response :unprocessable_entity
    assert_not_equal "new@bar.com", @user.reload.email

    patch user_path(@user), params: { user: { name: @user.name, email: @user.email, current_password: "wrong",
                                              password: "newpass123", password_confirmation: "newpass123" } }
    assert_response :unprocessable_entity
    assert @user.reload.authenticate("password")

    patch user_path(@user), params: { user: { name: @user.name, email: @user.email, current_password: "password",
                                              password: "newpass123", password_confirmation: "newpass123" } }
    assert @user.reload.authenticate("newpass123")
  end

  test "nickname alone can change without the current password" do
    log_in_as(@user)
    patch user_path(@user), params: { user: { name: "新しい名前", email: @user.email } }
    assert_equal "新しい名前", @user.reload.name
  end
end
