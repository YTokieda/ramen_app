class AdminMailer < ApplicationMailer
  def new_inquiry(inquiry)
    @inquiry = inquiry
    mail to: ENV.fetch("ADMIN_EMAIL", ApplicationMailer.default[:from]),
         subject: "[お問い合わせ] #{inquiry.category_label}"
  end
end
