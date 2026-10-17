require "test_helper"

class AccountActivationResendTest < ActionDispatch::IntegrationTest
  def setup
    ActionMailer::Base.deliveries.clear
    post users_path, params: { agree_terms: "1",
                               user: { name: "新規さん", email: "new@example.com",
                                       password: "password1", password_confirmation: "password1" } }
    @user = User.find_by(email: "new@example.com")
  end

  def token_from_last_mail
    ActionMailer::Base.deliveries.last.text_part.decoded[%r{account_activations/([^/]+)/edit}, 1]
  end

  test "signup mail mentions the 24 hour limit" do
    assert_not @user.activated?
    assert_not_nil @user.activation_sent_at
    assert_match "24時間", ActionMailer::Base.deliveries.last.text_part.decoded
  end

  test "unactivated login is sent to the resend page" do
    post login_path, params: { session: { email: "new@example.com", password: "password1" } }
    assert_redirected_to new_account_activation_path
  end

  test "resend sends a new link and the old one stops working" do
    old_token = token_from_last_mail
    assert_difference "ActionMailer::Base.deliveries.size", 1 do
      post account_activations_path, params: { account_activation: { email: " New@Example.com " } }
    end
    assert_redirected_to root_url
    new_token = token_from_last_mail
    assert_not_equal old_token, new_token

    get edit_account_activation_path(old_token, email: @user.email)
    assert_not @user.reload.activated?

    get edit_account_activation_path(new_token, email: @user.email)
    assert @user.reload.activated?
  end

  test "resend gives the same message for unknown or active accounts" do
    assert_no_difference "ActionMailer::Base.deliveries.size" do
      post account_activations_path, params: { account_activation: { email: "nobody@example.com" } }
      post account_activations_path, params: { account_activation: { email: users(:michael).email } }
    end
    assert_redirected_to root_url
  end

  test "expired link cannot activate" do
    token = token_from_last_mail
    travel 25.hours do
      get edit_account_activation_path(token, email: @user.email)
      assert_redirected_to new_account_activation_path
      assert_not @user.reload.activated?
    end
  end
end
