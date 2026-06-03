class Player < ApplicationRecord
  has_many :predictions, dependent: :destroy

  generates_token_for :magic_link, expires_in: 20.minutes do
    email
  end

  validates :name, presence: true
  validates :session_token, presence: true, uniqueness: true
  validates :email, uniqueness: { case_sensitive: false }, allow_nil: true
  validates :email, format: { with: URI::MailTo::EMAIL_REGEXP }, allow_nil: true

  before_validation :ensure_session_token, on: :create
  before_validation :normalize_email

  def initials
    name.to_s.split.map { |p| p[0] }.first(2).join.upcase
  end

  def registered? = email_verified_at.present?

  private

  def ensure_session_token
    self.session_token ||= SecureRandom.hex(16)
  end

  def normalize_email
    self.email = email.to_s.strip.downcase.presence
  end
end
