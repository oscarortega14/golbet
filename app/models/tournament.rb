class Tournament < ApplicationRecord
  has_many :matches, dependent: :destroy
  has_many :teams, dependent: :destroy
  has_many :pools, dependent: :destroy
  belongs_to :champion_team, class_name: "Team", optional: true

  validates :name, presence: true

  before_create :activate_if_first
  after_save :deactivate_others, if: -> { saved_change_to_active? && active? }

  # El único torneo activo, o nil si no hay ninguno.
  def self.active = find_by(active: true)

  def activate! = update!(active: true)

  def started?
    earliest = matches.minimum(:kickoff_at)
    earliest.present? && earliest <= Time.current
  end

  private

  def activate_if_first
    self.active = true unless Tournament.where(active: true).exists?
  end

  def deactivate_others
    Tournament.where.not(id: id).where(active: true).update_all(active: false)
  end
end
