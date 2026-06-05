class Pool < ApplicationRecord
  belongs_to :tournament
  belongs_to :owner, class_name: "Player", optional: true
  has_many :memberships, dependent: :destroy
  has_many :players, through: :memberships
  has_many :predictions, dependent: :destroy
  has_many :special_predictions, dependent: :destroy

  validates :name, presence: true
  validates :invite_token, presence: true, uniqueness: true
  validates :exact_points, :outcome_points, :champion_bonus, :top_scorer_bonus,
            numericality: { only_integer: true, greater_than_or_equal_to: 0 }

  def rules_locked? = tournament.started?

  before_validation :ensure_invite_token, on: :create

  def self.general_for(tournament) = find_by(tournament: tournament, public: true)

  private

  def ensure_invite_token
    self.invite_token ||= SecureRandom.urlsafe_base64(8)
  end
end
