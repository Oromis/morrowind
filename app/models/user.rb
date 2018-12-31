class User < ActiveRecord::Base
  attr_accessor :remember_token, :activation_token, :reset_token

  has_many :characters, dependent: :destroy

  VALID_EMAIL_REGEX = /\A[\w+\-.]+@[a-z\d\-.]+\.[a-z]+\z/i
  validates :name,  presence: true, 
                    length: { maximum: 50 }
  validates :email, presence: true, 
                    length: { maximum: 255 }, 
                    format: { with: VALID_EMAIL_REGEX },
                    uniqueness: { case_sensitive: false }

  before_save   :downcase_email
  before_create :create_activation_digest

  has_secure_password
  validates :password, presence: true,
                        length: { minimum: 6 },
                        allow_nil: true

  enum role: { guest: 0, user: 1, gm: 2, admin: 3 }

  # Returns true if the user has AT LEAST the required role 
  # (returns true for has_role(:gm) when the user is :admin)
  def has_role?(role) 
    case role.to_s
      when 'guest'
        true # Every user is at least a guest
      when 'user'
        user? || gm? || admin?
      when 'gm'
        gm? || admin?
      when 'admin'
        admin?
    end
  end

  def remember
    self.remember_token = User.new_token
    update_attribute(:remember_digest, User.digest(remember_token))
  end

  def forget
    update_attribute(:remember_digest, nil)
  end

  def authenticated?(attribute, token)
    digest = send("#{attribute}_digest")
    return false if digest.nil?
    BCrypt::Password.new(digest).is_password?(token)
  end

  def activate!
    update_columns(activated: true, activated_at: Time.zone.now)
  end

  def lock!(locked = true)
    update_column :locked, locked
  end

  def send_activation_email
    UserMailer.account_activation(self).deliver_now
  end

  def create_reset_digest
    self.reset_token = User.new_token
    update_columns(reset_digest: User.digest(reset_token),
                   reset_sent_at: Time.zone.now)
  end

  def send_password_reset_email
    UserMailer.password_reset(self).deliver_now
  end

  def password_reset_expired?
    reset_sent_at < 2.hours.ago
  end

  def User.digest(string)
    cost = ActiveModel::SecurePassword.min_cost ? BCrypt::Engine::MIN_COST : 
                                                  BCrypt::Engine.cost
    BCrypt::Password.create(string, cost: cost)
  end

  def User.new_token
    SecureRandom.urlsafe_base64
  end

  private
    def downcase_email
      self.email = email.downcase
    end
    
    def create_activation_digest
      self.activation_token = User.new_token
      self.activation_digest = User.digest(activation_token)
    end
end
