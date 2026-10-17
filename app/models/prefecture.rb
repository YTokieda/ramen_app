# 都道府県（JIS の順）。住所の文字列から都道府県を取り出すのに使う
module Prefecture
  LIST = [
    %w[北海道 Hokkaido], %w[青森県 Aomori], %w[岩手県 Iwate], %w[宮城県 Miyagi], %w[秋田県 Akita],
    %w[山形県 Yamagata], %w[福島県 Fukushima], %w[茨城県 Ibaraki], %w[栃木県 Tochigi], %w[群馬県 Gunma],
    %w[埼玉県 Saitama], %w[千葉県 Chiba], %w[東京都 Tokyo], %w[神奈川県 Kanagawa], %w[新潟県 Niigata],
    %w[富山県 Toyama], %w[石川県 Ishikawa], %w[福井県 Fukui], %w[山梨県 Yamanashi], %w[長野県 Nagano],
    %w[岐阜県 Gifu], %w[静岡県 Shizuoka], %w[愛知県 Aichi], %w[三重県 Mie], %w[滋賀県 Shiga],
    %w[京都府 Kyoto], %w[大阪府 Osaka], %w[兵庫県 Hyogo], %w[奈良県 Nara], %w[和歌山県 Wakayama],
    %w[鳥取県 Tottori], %w[島根県 Shimane], %w[岡山県 Okayama], %w[広島県 Hiroshima], %w[山口県 Yamaguchi],
    %w[徳島県 Tokushima], %w[香川県 Kagawa], %w[愛媛県 Ehime], %w[高知県 Kochi], %w[福岡県 Fukuoka],
    %w[佐賀県 Saga], %w[長崎県 Nagasaki], %w[熊本県 Kumamoto], %w[大分県 Oita], %w[宮崎県 Miyazaki],
    %w[鹿児島県 Kagoshima], %w[沖縄県 Okinawa]
  ].freeze

  NAMES = LIST.map(&:first).freeze
  PATTERN = Regexp.union(NAMES)

  def self.from_address(address)
    address.to_s[PATTERN]
  end

  def self.label(name, locale = I18n.locale)
    return name unless locale.to_sym == :en
    LIST.find { |ja, _| ja == name }&.last || name
  end

  def self.order_index(name)
    NAMES.index(name) || NAMES.size
  end
end
