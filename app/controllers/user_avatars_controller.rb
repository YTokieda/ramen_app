class UserAvatarsController < ApplicationController
  def show
    user = User.find(params[:user_id])
    blob = user.avatar.attached? ? user.avatar.blob : nil

    unless user.activated? && blob && User::AVATAR_TYPES.include?(blob.content_type)
      raise ActiveRecord::RecordNotFound
    end

    # URL に画像ごとの番号が入るので、ブラウザに長めに保存させて通信量を抑える
    expires_in 7.days, public: true
    response.headers["X-Content-Type-Options"] = "nosniff"

    send_data blob.download,
              filename: "avatar",
              type: blob.content_type,
              disposition: "inline"
  end
end
