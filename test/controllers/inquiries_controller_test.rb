require "test_helper"

class InquiriesControllerTest < ActionDispatch::IntegrationTest
  include ActionMailer::TestHelper

  def valid_params
    { inquiry: { category: "wrong_info", name: "山田", email: "yamada@example.com",
                 body: "麺の卵情報が古いようです。" } }
  end

  test "contact page shows the form" do
    get contact_path
    assert_response :success
    assert_select "form[action=?]", inquiries_path
    assert_select "select[name=?]", "inquiry[category]"
  end

  test "logged in user gets name and email prefilled" do
    user = users(:archer)
    log_in_as(user)
    get new_inquiry_path
    assert_select "input[name=?][value=?]", "inquiry[email]", user.email
  end

  test "valid inquiry is saved and admin is notified" do
    assert_difference "Inquiry.count", 1 do
      assert_emails 1 do
        post inquiries_path, params: valid_params
      end
    end
    assert_redirected_to root_path
    inquiry = Inquiry.last
    assert_equal "new", inquiry.status
    assert_nil inquiry.user
  end

  test "inquiry from logged in user is linked to the user" do
    log_in_as(users(:archer))
    post inquiries_path, params: valid_params
    assert_equal users(:archer), Inquiry.last.user
  end

  test "invalid inquiry is not saved" do
    assert_no_difference "Inquiry.count" do
      post inquiries_path, params: { inquiry: { category: "bogus", name: "", email: "bad", body: "" } }
    end
    assert_response :unprocessable_entity
    assert_select "div#error_explanation"
  end

  test "honeypot submission is silently dropped" do
    assert_no_difference "Inquiry.count" do
      assert_no_emails do
        post inquiries_path, params: valid_params.merge(website: "http://spam.example")
      end
    end
    assert_redirected_to root_path
  end

  test "inquiry is kept even if admin notification fails" do
    AdminMailer.stub(:new_inquiry, ->(_) { raise "mail down" }) do
      assert_difference "Inquiry.count", 1 do
        post inquiries_path, params: valid_params
      end
    end
    assert_redirected_to root_path
  end
end
