class ApplicationController < ActionController::Base
  include SessionsHelper
  helper_method :current_shop_owner, :shop_owner_logged_in?

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
  
  
  def current_shop_owner
    return @current_shop_owner if defined?(@current_shop_owner)
    if session[:shop_owner_id]
      @current_shop_owner = ShopOwner.find_by(id: session[:shop_owner_id])
    end
  end

  def shop_owner_logged_in?
    current_shop_owner.present?
  end

  def require_shop_owner
    unless shop_owner_logged_in?
      flash[:alert] = "店舗アカウントでログインしてください。"
      redirect_to shop_owner_login_path
    end
  end
  
    private

    def logged_in_user
      unless logged_in?
        store_location
        flash[:danger] = "ログインしてください。"
        redirect_to login_url, status: :see_other
      end
    end
    
    def admin_user
      unless logged_in? && current_user.admin?
        redirect_to(root_url, status: :see_other)
      end
    end
  
end