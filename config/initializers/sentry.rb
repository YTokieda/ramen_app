# 本番で起きたエラーを Sentry に送って、メールで気づけるようにする。
# Render の環境変数 SENTRY_DSN を設定したときだけ有効になる。
if ENV["SENTRY_DSN"].present?
  Sentry.init do |config|
    config.dsn = ENV["SENTRY_DSN"]
    config.environment = Rails.env
    config.enabled_environments = %w[production]
    config.breadcrumbs_logger = [:active_support_logger]
    # 利用者のIPアドレスやクッキーなどの個人情報は送らない
    config.send_default_pii = false
    # 速度の計測は使わない（無料枠の節約）
    config.traces_sample_rate = 0.0
  end
end
