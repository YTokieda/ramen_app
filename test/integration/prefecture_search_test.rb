require "test_helper"

class PrefectureSearchTest < ActionDispatch::IntegrationTest
  def setup
    @tokyo = Shop.create!(name: "東京の店", address: "〒160-0023 東京都新宿区西新宿1-1")
    @kyoto = Shop.create!(name: "京都の店", address: "京都府京都市中京区1-1")
  end

  test "prefecture is taken from the address" do
    assert_equal "東京都", @tokyo.prefecture
    assert_equal "京都府", @kyoto.prefecture
    assert_nil Shop.create!(name: "不明の店", address: "どこか").prefecture
  end

  test "prefecture follows address edits" do
    @kyoto.update!(address: "大阪府大阪市北区1-1")
    assert_equal "大阪府", @kyoto.reload.prefecture
  end

  test "search filters by prefecture and ignores unknown values" do
    get shops_path, params: { prefecture: "京都府" }
    assert_select "a", text: "京都の店"
    assert_select "a", text: "東京の店", count: 0

    get shops_path, params: { prefecture: "<script>" }
    assert_select "a", text: "東京の店"
  end

  test "the select lists prefectures that have shops with counts" do
    get shops_path
    assert_select "select[name=prefecture] option[value=?]", "京都府"
    assert_select "select[name=prefecture] option[value=?]", "沖縄県", count: 0
  end

  test "shop page links to the map" do
    get shop_path(@tokyo)
    assert_select "a.shop-map-link[href^=?][target=_blank]", "https://www.google.com/maps/search/?api=1&query="
  end
end
