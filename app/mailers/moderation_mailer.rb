# 投稿者に、運営の審査結果を知らせる
class ModerationMailer < ApplicationMailer
  KINDS = {
    "shop_submission" => "店舗情報",
    "verification"    => "卵情報",
    "shop_owner"      => "店舗オーナー申請"
  }.freeze

  def result(user:, kind:, approved:, subject_name:, link_url:)
    @user = user
    @kind_label = KINDS.fetch(kind)
    @kind = kind
    @approved = approved
    @subject_name = subject_name
    @link_url = link_url
    title = approved ? "#{@kind_label}が承認されました" : "#{@kind_label}の審査結果のお知らせ"
    mail to: user.email, subject: "【#{ApplicationHelper::SITE_NAME}】#{title}"
  end

  # 管理画面の操作が、メールの失敗で止まらないようにする
  def self.notify(user:, **args)
    return if user.nil? || !user.activated? || user.withdrawn?

    result(user: user, **args).deliver_now
  rescue StandardError => e
    Rails.logger.error("[ModerationMailer] #{e.class}: #{e.message}")
    Sentry.capture_exception(e) if defined?(Sentry) && Sentry.initialized?
  end
end
