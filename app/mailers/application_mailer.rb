class ApplicationMailer < ActionMailer::Base
  helper ApplicationHelper
  default from: "y.tokieda@gmail.com"
  layout "mailer"
end
