class Match < ApplicationRecord
  belongs_to :tournament
  belongs_to :home_team, class_name: "Team", optional: true
  belongs_to :away_team, class_name: "Team", optional: true
  has_many :predictions, dependent: :destroy

  STATUSES = %w[scheduled finished].freeze
  STAGES = %w[group round_of_32 round_of_16 quarter_final semi_final third_place final].freeze

  validates :kickoff_at, presence: true
  validates :status, inclusion: { in: STATUSES }
  validates :stage, inclusion: { in: STAGES }

  after_initialize do
    self.status ||= "scheduled"
    self.stage  ||= "group"
  end

  def finished? = status == "finished"
  def locked? = kickoff_at.present? && Time.current >= kickoff_at
  def teams_set? = home_team_id.present? && away_team_id.present?
  def tbd? = !teams_set?
  def predictable? = teams_set? && !locked?
  def display_home = home_team&.name || home_label || "Por definir"
  def display_away = away_team&.name || away_label || "Por definir"
end
