require "test_helper"

class StaticPagesControllerTest < ActionDispatch::IntegrationTest

  test "should get home" do
    get root_path
    assert_response :success
    assert_select "title", "卵アレルギーの方のためのラーメンガイド"
  end

  test "should get help" do
    get help_path
    assert_response :success
    assert_select "title", "ヘルプ | 卵アレルギーの方のためのラーメンガイド"
  end

  test "should get about" do
    get about_path
    assert_response :success
    assert_select "title", "このサイトについて | 卵アレルギーの方のためのラーメンガイド"
  end

  test "should get contact" do
    get contact_path
    assert_response :success
    assert_select "title", "お問い合わせ | 卵アレルギーの方のためのラーメンガイド"
  end
end