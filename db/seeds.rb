User.create!(
  name: "Example User",
  email: "example@railstutorial.org",
  password: "foobar",
  password_confirmation: "foobar",
  admin: true,
  activated: true,
  activated_at: Time.zone.now
)

Shop.create!(
  name: "ラーメン一郎",
  address: "東京都新宿区1-1-1",
  description: "こってり系ラーメン",
  egg_free: false
)