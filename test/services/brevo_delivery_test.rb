require "test_helper"

class BrevoDeliveryTest < ActiveSupport::TestCase
  FakeHTTP = Struct.new(:response, :requests) do
    def request(req)
      requests << req
      response
    end
  end

  def setup
    @user = users(:michael)
    @user.activation_token = User.new_token
    @original_key = ENV["BREVO_API_KEY"]
    ENV["BREVO_API_KEY"] = "test-key"
  end

  def teardown
    ENV["BREVO_API_KEY"] = @original_key
  end

  def success_response
    Net::HTTPCreated.new("1.1", "201", "Created")
  end

  def error_response
    response = Net::HTTPBadRequest.new("1.1", "400", "Bad Request")
    response.instance_variable_set(:@read, true)
    response.instance_variable_set(:@body, '{"message":"invalid"}')
    response
  end

  def deliver_with(response)
    http = FakeHTTP.new(response, [])
    original_method = ActionMailer::Base.delivery_method
    # 本番と同じく ActionMailer 経由で :brevo を使って送信する
    ActionMailer::Base.delivery_method = :brevo
    Net::HTTP.stub(:start, ->(*_args, **_opts, &block) { block.call(http) }) do
      UserMailer.account_activation(@user).deliver_now
    end
    http.requests
  ensure
    ActionMailer::Base.delivery_method = original_method
  end

  test ":brevo is registered as an ActionMailer delivery method" do
    assert_includes ActionMailer::Base.delivery_methods.keys, :brevo
    assert_equal BrevoDelivery, ActionMailer::Base.delivery_methods[:brevo]
  end

  test "can be instantiated by the Mail gem with settings" do
    delivery = BrevoDelivery.new({})
    assert_equal({}, delivery.settings)
  end

  test "posts sender, recipient, subject and multipart bodies to Brevo" do
    requests = deliver_with(success_response)

    assert_equal 1, requests.size
    request = requests.first
    assert_equal "test-key", request["api-key"]

    payload = JSON.parse(request.body)
    assert_equal "ramen-guide@tokworks.jp", payload["sender"]["email"]
    assert_equal "たまナビ", payload["sender"]["name"]
    assert_equal [{ "email" => @user.email }], payload["to"]
    assert_equal "【たまナビ】アカウントの有効化", payload["subject"]
    assert_match @user.activation_token, payload["htmlContent"]
    assert_match @user.activation_token, payload["textContent"]
  end

  test "raises when Brevo returns an error response" do
    error = assert_raises(RuntimeError) { deliver_with(error_response) }
    assert_match "HTTP 400", error.message
  end
end
