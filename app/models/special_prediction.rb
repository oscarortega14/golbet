class SpecialPrediction < ApplicationRecord
  belongs_to :player
  belongs_to :tournament
  belongs_to :champion_team, class_name: "Team", optional: true

  validates :tournament_id, uniqueness: { scope: :player_id }
  validate :champion_in_tournament
  validate :tournament_not_started

  def self.normalize(str)
    str.to_s.unicode_normalize(:nfkd).gsub(/\p{Mn}/, "")
       .downcase.strip.gsub(/\s+/, " ")
  end

  private

  def champion_in_tournament
    return if champion_team.blank?
    errors.add(:champion_team, "no pertenece a este torneo") if champion_team.tournament_id != tournament_id
  end

  def tournament_not_started
    return if tournament.blank?
    errors.add(:base, "El torneo ya comenzó, no se puede cambiar tu predicción especial") if tournament.started?
  end
end
