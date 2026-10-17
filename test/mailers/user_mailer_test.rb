require "test_helper"

class UserMailerTest < ActionMailer::TestCase

  test "account_activation" do
    user = users(:michael)
    user.activation_token = User.new_token
    mail = UserMailer.account_activation(user)
    assert_equal "【Tamago free】アカウントの有効化", mail.subject
    assert_equal [user.email], mail.to
    assert_equal ["ramen-guide@tokworks.jp"], mail.from
    assert_match user.name,               mail.text_part.decoded
    assert_match user.activation_token,   mail.text_part.decoded
    assert_match CGI.escape(user.email),  mail.text_part.decoded
  end
  
  test "password_reset" do
    user = users(:michael)
    user.reset_token = User.new_token
    mail = UserMailer.password_reset(user)
    assert_equal "【Tamago free】パスワードの再設定", mail.subject
    assert_equal [user.email], mail.to
    assert_equal ["ramen-guide@tokworks.jp"], mail.from
    assert_match user.reset_token,        mail.text_part.decoded
    assert_match CGI.escape(user.email),  mail.text_part.decoded
  end
end