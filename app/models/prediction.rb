class Prediction < ApplicationRecord
  belongs_to :player
  belongs_to :match
  belongs_to :pool

  validates :home_pred, :away_pred,
            presence: true,
            numericality: { only_integer: true, greater_than_or_equal_to: 0 }
  validates :match_id, uniqueness: { scope: [:player_id, :pool_id] }
  validate :match_not_locked
  validate :match_has_teams

  private

  def match_not_locked
    return if match.blank?
    errors.add(:base, "El partido ya comenzó, no se puede pronosticar") if match.locked?
  end

  def match_has_teams
    return if match.blank?
    errors.add(:base, "Este partido aún no tiene equipos definidos") unless match.teams_set?
  end
end
