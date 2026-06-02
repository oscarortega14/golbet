class Prediction < ApplicationRecord
  belongs_to :player
  belongs_to :match

  validates :home_pred, :away_pred,
            presence: true,
            numericality: { only_integer: true, greater_than_or_equal_to: 0 }
  validates :match_id, uniqueness: { scope: :player_id }
  validate :match_not_locked

  private

  def match_not_locked
    return if match.blank?
    errors.add(:base, "El partido ya comenzó, no se puede pronosticar") if match.locked?
  end
end
