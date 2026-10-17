class User < ApplicationRecord
    has_many :reviews, dependent: :destroy
    has_many :shop_owners, dependent: :destroy
    has_many :owned_shops, through: :shop_owners, source: :shop
    has_many :shop_submissions, dependent: :destroy
    has_many :verifications
    has_many :review_reactions, dependent: :destroy
    # プロフィール画像（口コミなどに表示される）
    has_one_attached :avatar
    AVATAR_TYPES = %w[image/jpeg image/png image/webp].freeze
    AVATAR_MAX_SIZE = 5.megabytes

    attr_accessor :remember_token, :activation_token, :reset_token
    before_save   :downcase_email
    before_create :create_activation_digest
    # name は公開されるニックネーム（本名は入力しない運用）
    validates :name, presence:true, length: { maximum:30}
    VALID_EMAIL_REGEX = /\A[\w+\-.]+@[a-z\d\-.]+\.[a-z]+\z/i
    validates :email, presence: true, length: { maximum: 255 },
                                format: { with: VALID_EMAIL_REGEX },
                                uniqueness: true
    has_secure_password
    PASSWORD_FORMAT = /\A(?=.*[A-Za-z])(?=.*\d).{8,72}\z/
    validates :password, presence: true, allow_nil: true,
                         format: { with: PASSWORD_FORMAT, message: :password_complexity }
    
  # 店舗のメニューなどを編集できるか（承認済みのオーナーか運営）
  def can_manage_shop?(shop)
    admin? || shop_owners.where(shop: shop, status: "approved").exists?
  end

  # 運営に承認された店舗オーナーか（店舗管理メニューの表示に使う）
  def approved_shop_owner?
    shop_owners.where(status: "approved").exists?
  end

  def User.digest(string)
    cost = ActiveModel::SecurePassword.min_cost ? BCrypt::Engine::MIN_COST :
                                                  BCrypt::Engine.cost
    BCrypt::Password.create(string, cost: cost)
  end
  
  def User.new_token
    SecureRandom.urlsafe_base64
  end
  
  def remember
    self.remember_token = User.new_token
    update_attribute(:remember_digest, User.digest(remember_token))
    remember_digest
  end
  
  def session_token
    remember_digest || remember
  end
  
  def authenticated?(attribute, token)
    digest = send("#{attribute}_digest")
    return false if digest.nil?
    BCrypt::Password.new(digest).is_password?(token)
  end
  
  
  def forget
    update_attribute(:remember_digest, nil)
  end
  
  def activate
    update_attribute(:activated,    true)
    update_attribute(:activated_at, Time.zone.now)
  end

  # 有効化用のメールを送信する
  def send_activation_email
    UserMailer.account_activation(self).deliver_now
  end

  # パスワード再設定の属性を設定する
  def create_reset_digest
    self.reset_token = User.new_token
    update_attribute(:reset_digest,  User.digest(reset_token))
    update_attribute(:reset_sent_at, Time.zone.now)
  end

  # パスワード再設定のメールを送信する
  def send_password_reset_email
    UserMailer.password_reset(self).deliver_now
  end
  
  def password_reset_expired?
    reset_sent_at < 2.hours.ago
  end
  

  def withdrawn?
    withdrawn_at.present?
  end

  
  private
    # メールアドレスをすべて小文字にする
    def downcase_email
      self.email = email.downcase
    end
    # 有効化トークンとダイジェストを作成および代入する
    def create_activation_digest
      self.activation_token  = User.new_token
      self.activation_digest = User.digest(activation_token)
    end
    
end
