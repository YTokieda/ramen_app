class ApplicationMailer < ActionMailer::Base
  helper ApplicationHelper
  default from: email_address_with_name("ramen-guide@tokworks.jp", ApplicationHelper::SITE_NAME)
  layout "mailer"

  # メール内のURLは日本語ページ（接頭辞なし）にし、
  # 位置引数のパスヘルパーが (:locale) に割り当てられないようにする
  def default_url_options
    super.merge(locale: nil)
  end
end
