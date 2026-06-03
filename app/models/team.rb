class Team < ApplicationRecord
  belongs_to :tournament
  has_many :home_matches, class_name: "Match", foreign_key: :home_team_id, dependent: :nullify
  has_many :away_matches, class_name: "Match", foreign_key: :away_team_id, dependent: :nullify

  validates :name, :code, :group, presence: true
  validates :code, uniqueness: { scope: :tournament_id }

  def label = "#{flag} #{name}".strip
  def initials = code.presence || name.to_s[0, 3].upcase
end
