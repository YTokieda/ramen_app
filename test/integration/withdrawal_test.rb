require "test_helper"

class WithdrawalTest < ActionDispatch::IntegrationTest
  def setup
    @user = users(:archer)
  end

  test "requires login" do
    get new_withdrawal_path
    assert_redirected_to login_url
  end

  test "wrong password does not withdraw" do
    log_in_as(@user)
    post withdrawal_path, params: { withdrawal: { password: "wrong" } }
    assert_response :unprocessable_entity
    assert_not @user.reload.withdrawn?
  end

  test "withdrawal removes personal data, keeps verifications anonymously and logs out" do
    review = Review.create!(user: @user, shop: shops(:one), content: "消える口コミ")
    verification = Verification.where(user: @user).first
    old_email = @user.email
    log_in_as(@user)

    post withdrawal_path, params: { withdrawal: { password: "password" } }
    assert_redirected_to root_url
    assert_not is_logged_in?

    @user.reload
    assert @user.withdrawn?
    assert_equal User::WITHDRAWN_NAME, @user.name
    assert_not_equal old_email, @user.email
    assert_not Review.exists?(review.id)
    assert verification.nil? || Verification.exists?(verification.id)

    # 同じメールアドレスではログインできず、再登録はできる
    post login_path, params: { session: { email: old_email, password: "password" } }
    assert_not is_logged_in?
    get user_path(@user)
    assert_redirected_to root_url
    assert User.new(name: "再登録", email: old_email, password: "password1",
                    password_confirmation: "password1").valid?
  end
end
