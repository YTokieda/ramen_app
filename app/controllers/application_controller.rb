class ApplicationController < ActionController::Base
  include SessionsHelper

  before_action :redirect_to_canonical_host
  around_action :switch_locale

  # CANONICAL_HOST（例：ramen.tokworks.jp）が設定されていれば、
  # 旧URL（onrender.com など）へのGETアクセスを同じパスのまま301転送する
  def redirect_to_canonical_host
    canonical = ENV["CANONICAL_HOST"].presence
    return if canonical.nil? || request.host == canonical || !request.get?

    redirect_to "#{request.protocol}#{canonical}#{request.fullpath}",
                status: :moved_permanently, allow_other_host: true
  end

  # 日本語は接頭辞なし、英語は /en/... で表示する
  def switch_locale(&action)
    locale = params[:locale] == "en" ? :en : I18n.default_locale
    I18n.with_locale(locale, &action)
  end

  # locale キーを常に含めることで、shop_path(shop) のような位置引数が
  # 省略可能な (:locale) セグメントに割り当てられるのを防ぐ
  def default_url_options
    { locale: I18n.locale == I18n.default_locale ? nil : I18n.locale }
  end
  
  
    private

    def logged_in_user
      unless logged_in?
        store_location
        flash[:danger] = "ログインしてください。"
        redirect_to login_url, status: :see_other
      end
    end
    
    # 非公開の店舗は管理者にだけ見せる（ほかの人には存在しない扱い）
    def find_shop(id)
      scope = logged_in? && current_user.admin? ? Shop.all : Shop.visible
      scope.find(id)
    end

    def admin_user
      unless logged_in? && current_user.admin?
        redirect_to(root_url, status: :see_other)
      end
    end
  
end