namespace :admin do
  # 環境変数 ADMIN_EMAILS（カンマ区切り）に書かれた登録済みユーザーを管理者にする。
  # Render のビルド時に毎回実行される。未設定なら何もしない。
  # 管理者を外すことはしない（外すときは管理画面かコンソールで行う）。
  desc "Grant admin to activated users listed in ADMIN_EMAILS"
  task grant_from_env: :environment do
    emails = ENV["ADMIN_EMAILS"].to_s.split(",").map { |e| e.strip.downcase }.reject(&:empty?)
    next if emails.empty?

    emails.each do |email|
      user = User.find_by(email: email)
      if user.nil?
        puts "[admin] #{email}: 未登録のため何もしません"
      elsif !user.activated?
        puts "[admin] #{email}: 登録確認が済んでいないため何もしません"
      elsif user.admin?
        puts "[admin] #{email}: すでに管理者です"
      else
        user.update_column(:admin, true)
        puts "[admin] #{email}: 管理者にしました"
      end
    end
  end
end
