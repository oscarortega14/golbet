class Player < ApplicationRecord
  has_many :predictions, dependent: :destroy

  validates :name, presence: true
  validates :session_token, presence: true, uniqueness: true

  before_validation :ensure_session_token, on: :create

  def initials
    name.to_s.split.map { |p| p[0] }.first(2).join.upcase
  end

  private

  def ensure_session_token
    self.session_token ||= SecureRandom.hex(16)
  end
end
