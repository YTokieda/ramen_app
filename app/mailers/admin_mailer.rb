class AdminMailer < ApplicationMailer
  def new_inquiry(inquiry)
    @inquiry = inquiry
    mail to: ENV.fetch("ADMIN_EMAIL", ApplicationHelper::CONTACT_EMAIL),
         subject: "[お問い合わせ] #{inquiry.category_label}"
  end
end
