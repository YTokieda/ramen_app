# Brevo HTTP API をActionMailerの配信方式 :brevo として登録する
# （config.action_mailer.add_delivery_method は設定値として無視されるため、ここで登録する）
ActiveSupport.on_load(:action_mailer) do
  add_delivery_method :brevo, BrevoDelivery
end
