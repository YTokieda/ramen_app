# 開発・動作確認用のサンプルデータ（店舗はすべて架空）
# 何度実行しても重複しないように find_or_create_by! を使う

def seed_user(name:, email:, admin: false)
  User.find_or_create_by!(email: email) do |user|
    user.name = name
    user.password = "foobar"
    user.password_confirmation = "foobar"
    user.admin = admin
    user.activated = true
    user.activated_at = Time.zone.now
  end
end

admin = seed_user(name: "Example User", email: "example@railstutorial.org", admin: true)
user  = seed_user(name: "卵アレルギーの子の親", email: "parent@example.com")
owner = seed_user(name: "麺処さくら 店主", email: "owner@example.com")

shops = [
  { name: "麺処さくら（サンプル）", address: "東京都新宿区西新宿1-1-1",
    description: "鶏白湯スープの店。卵不使用の麺を使用していると店舗から回答あり。" },
  { name: "らーめん青空（サンプル）", address: "東京都渋谷区道玄坂2-2-2",
    description: "醤油ラーメンの店。" },
  { name: "中華そば 灯（サンプル）", address: "大阪府大阪市北区梅田3-3-3",
    description: "煮干し中華そばの店。" },
  { name: "つけ麺 一歩（サンプル）", address: "福岡県福岡市博多区博多駅前4-4-4",
    description: "つけ麺専門店。卵情報はまだ確認されていない。" }
].map do |attrs|
  Shop.find_or_create_by!(name: attrs[:name], address: attrs[:address]) do |shop|
    shop.description = attrs[:description]
  end
end

sakura, aozora, akari, ippo = shops

menu = {}
[
  [sakura, "鶏白湯ラーメン"], [sakura, "鶏白湯つけ麺"],
  [aozora, "醤油ラーメン"], [aozora, "味玉醤油ラーメン"],
  [akari,  "煮干し中華そば"],
  [ippo,   "濃厚つけ麺"]
].each do |shop, name|
  menu[[shop.id, name]] = MenuItem.find_or_create_by!(shop: shop, name: name)
end

def seed_verification(shop:, menu_item: nil, category:, egg_status:, verified_on:,
                      user:, source_type:, method:, status: "approved", note: nil)
  Verification.find_or_create_by!(
    shop: shop, menu_item: menu_item, category: category,
    egg_status: egg_status, verified_on: verified_on, user: user
  ) do |v|
    v.source_type = source_type
    v.verification_method = method
    v.status = status
    v.note = note
  end
end

today = Date.current

# 最近確認された情報（卵不使用）
seed_verification(shop: sakura, menu_item: menu[[sakura.id, "鶏白湯ラーメン"]],
                  category: "noodle_soup", egg_status: "egg_free",
                  verified_on: today - 20, user: owner, source_type: "shop_owner",
                  method: "店舗オーナーが麺の成分表を提出")
seed_verification(shop: sakura, menu_item: menu[[sakura.id, "鶏白湯ラーメン"]],
                  category: "topping", egg_status: "egg_free",
                  verified_on: today - 20, user: owner, source_type: "shop_owner",
                  method: "店舗オーナーへの聞き取り")
seed_verification(shop: sakura, category: "cooking_environment", egg_status: "contains_egg",
                  verified_on: today - 20, user: owner, source_type: "shop_owner",
                  method: "店舗オーナーへの聞き取り",
                  note: "味玉を同じ厨房で扱っています。")

# 古い情報（1年以上前）
seed_verification(shop: aozora, menu_item: menu[[aozora.id, "醤油ラーメン"]],
                  category: "noodle_soup", egg_status: "egg_free",
                  verified_on: today - 400, user: user, source_type: "staff",
                  method: "来店時に店舗スタッフへ口頭で確認")
seed_verification(shop: aozora, menu_item: menu[[aozora.id, "味玉醤油ラーメン"]],
                  category: "topping", egg_status: "contains_egg",
                  verified_on: today - 400, user: user, source_type: "official",
                  method: "公式サイトのメニュー表記")

# 同じ日に食い違う情報（矛盾あり）
seed_verification(shop: akari, menu_item: menu[[akari.id, "煮干し中華そば"]],
                  category: "noodle_soup", egg_status: "egg_free",
                  verified_on: today - 60, user: user, source_type: "user_report",
                  method: "店舗に電話で確認")
seed_verification(shop: akari, menu_item: menu[[akari.id, "煮干し中華そば"]],
                  category: "noodle_soup", egg_status: "contains_egg",
                  verified_on: today - 60, user: admin, source_type: "manufacturer",
                  method: "製麺所の公開資料")

# 運営確認待ち
seed_verification(shop: ippo, menu_item: menu[[ippo.id, "濃厚つけ麺"]],
                  category: "noodle_soup", egg_status: "egg_free",
                  verified_on: today - 3, user: user, source_type: "user_report",
                  method: "来店時に店舗スタッフへ口頭で確認", status: "pending")

Review.find_or_create_by!(user: user, shop: sakura,
                          content: "子どもと一緒に行きました。麺の成分表を見せてもらえて安心できました。")
Review.find_or_create_by!(user: user, shop: aozora,
                          content: "スタッフの方が丁寧に教えてくれました。")

ShopOwner.find_or_create_by!(user: owner, shop: sakura) { |o| o.status = "approved" }

ShopSubmission.find_or_create_by!(user: user, name: "らーめん新店（サンプル）",
                                  address: "東京都豊島区池袋5-5-5") do |s|
  s.description = "近所に新しくできた店です。"
end

puts "Seed完了: users=#{User.count}, shops=#{Shop.count}, verifications=#{Verification.count}"
