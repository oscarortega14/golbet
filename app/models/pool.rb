class Pool < ApplicationRecord
  belongs_to :tournament
  belongs_to :owner, class_name: "Player", optional: true
  belongs_to :focus_match, class_name: "Match", optional: true
  has_many :memberships, dependent: :destroy
  has_many :players, through: :memberships
  has_many :predictions, dependent: :destroy
  has_many :special_predictions, dependent: :destroy

  MODALITIES = %w[stages match].freeze

  serialize :stages, coder: JSON

  validates :name, presence: true
  validates :invite_token, presence: true, uniqueness: true
  validates :exact_points, :outcome_points, :champion_bonus, :top_scorer_bonus,
            numericality: { only_integer: true, greater_than_or_equal_to: 0 }
  validates :modality, inclusion: { in: MODALITIES }
  validate :stages_valid, if: -> { modality == "stages" }
  validate :focus_match_in_tournament, if: -> { modality == "match" }

  before_validation :ensure_invite_token, on: :create

  def self.general_for(tournament) = find_by(tournament: tournament, public: true)

  def rules_locked? = tournament.started?

  def effective_stages
    s = stages.presence
    s ? s.map(&:to_s) : Match::STAGES
  end

  def full_tournament?
    modality == "stages" && effective_stages.sort == Match::STAGES.sort
  end

  def matches_in_scope
    return tournament.matches.where(id: focus_match_id) if modality == "match"
    tournament.matches.where(stage: effective_stages)
  end

  def special_available?
    special_enabled && full_tournament?
  end

  private

  def ensure_invite_token
    self.invite_token ||= SecureRandom.urlsafe_base64(8)
  end

  def stages_valid
    return if stages.nil? # nil = todas las fases (torneo completo)
    if !stages.is_a?(Array) || stages.empty? || (stages.map(&:to_s) - Match::STAGES).any?
      errors.add(:stages, "deben ser fases válidas del torneo")
    end
  end

  def focus_match_in_tournament
    if focus_match_id.blank?
      errors.add(:focus_match, "es obligatorio para la modalidad de un partido")
    elsif focus_match.nil? || focus_match.tournament_id != tournament_id
      errors.add(:focus_match, "debe pertenecer al torneo de la polla")
    end
  end
end
