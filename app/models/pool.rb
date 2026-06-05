class Pool < ApplicationRecord
  belongs_to :tournament
  belongs_to :owner, class_name: "Player", optional: true
  has_many :memberships, dependent: :destroy
  has_many :players, through: :memberships
  has_many :predictions, dependent: :destroy
  has_many :special_predictions, dependent: :destroy

  validates :name, presence: true
  validates :invite_token, presence: true, uniqueness: true

  before_validation :ensure_invite_token, on: :create

  def self.general = find_by(public: true)

  private

  def ensure_invite_token
    self.invite_token ||= SecureRandom.urlsafe_base64(8)
  end
end
