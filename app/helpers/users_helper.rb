module UsersHelper
  # プロフィール画像。未設定ならニックネームの1文字目を丸の中に表示する
  def user_avatar(user, size: 40)
    style = "width: #{size}px; height: #{size}px;"
    if user.avatar.attached?
      image_tag user_avatar_path(user, v: user.avatar.blob.id),
                alt: "", class: "avatar", width: size, height: size,
                loading: "lazy", style: style
    else
      tag.span(user.name.to_s.first, class: "avatar avatar--initial", aria: { hidden: true },
               style: style + " font-size: #{(size * 0.45).round}px;")
    end
  end
end
