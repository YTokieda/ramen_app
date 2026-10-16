class ApplicationMailer < ActionMailer::Base
  helper ApplicationHelper
  default from: "y.tokieda@gmail.com"
  layout "mailer"

  # メール内のURLは日本語ページ（接頭辞なし）にし、
  # 位置引数のパスヘルパーが (:locale) に割り当てられないようにする
  def default_url_options
    super.merge(locale: nil)
  end
end
